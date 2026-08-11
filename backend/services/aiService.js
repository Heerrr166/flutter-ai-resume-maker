// Hybrid AI provider layer.
//
//   controller -> aiService (this file) -> GeminiProvider | LocalProvider (resumeIntelligenceEngine)
//
// Every exported function here tries Gemini first (when configured) for the
// natural-language tasks it's actually good at, and always falls back to the
// local, zero-cost, deterministic Resume Intelligence Engine if Gemini is
// unavailable, rate-limited, times out, or returns something unusable. The
// user-facing behavior never breaks just because Gemini had a bad moment.
//
// Purely deterministic tasks (numeric ATS score, literal keyword matching,
// skill-cluster recommendations) stay 100% local by design - an LLM has no
// business inventing a resume's score.
//
// Every prompt below is instructed to use ONLY facts supplied by the caller
// and to never invent employers, degrees, technologies, metrics, or
// achievements - see SYSTEM_PROMPT.
const engine = require('./resumeIntelligenceEngine');
const geminiProvider = require('./providers/geminiProvider');

const SYSTEM_PROMPT = `You are an AI writing assistant embedded in "AI Resume Maker", a resume-building application.
Strict rules you must always follow:
1. Use ONLY facts explicitly provided in the user message. Never invent employers, job titles, companies, degrees, institutions, certifications, technologies, dates, metrics, percentages, team sizes, revenue, user counts, or years of experience that were not supplied.
2. If a claim would require information you were not given, omit it rather than guessing or estimating.
3. Do not exaggerate accomplishments beyond what the provided facts support.
4. Write in a clear, professional, concise, ATS-friendly style.
5. Never wrap output in markdown code fences and never add commentary or a preamble - return exactly what is requested, nothing else.`;

const logFallback = (feature, error) => {
  // Deliberately no prompt/candidate-data logging here - only the failure
  // classification, so candidate resume content never hits server logs.
  console.warn(`[ai] Gemini call failed for ${feature} (status=${error && error.status}), falling back to local engine`);
};

// ---------- plain-text features ----------

const generateSummary = async (payload) => {
  if (geminiProvider.isConfigured()) {
    try {
      const { currentSummary, experience = [], skills = [], education = [] } = payload;
      const facts = JSON.stringify({ currentSummary: currentSummary || null, experience, skills, education });
      const text = await geminiProvider.complete({
        system: SYSTEM_PROMPT,
        prompt: `Write a concise, professional 2-4 sentence resume summary using ONLY the facts below. If a current summary is given, refine/tighten it rather than starting over; otherwise write a new one from the experience/skills/education.\n\nFacts (JSON):\n${facts}\n\nReturn only the summary text - no quotes, no heading.`,
        maxTokens: 300,
      });
      if (text) return text.trim();
    } catch (error) {
      logFallback('generateSummary', error);
    }
  }
  return engine.generateSummary(payload);
};

const improveExperience = async (payload) => {
  if (geminiProvider.isConfigured()) {
    try {
      const { text, position, company } = payload;
      const text_ = await geminiProvider.complete({
        system: SYSTEM_PROMPT,
        prompt: `Rewrite the following rough experience description into 2-4 strong, professional resume bullet points. Use ONLY facts stated in the input - do not add numbers, percentages, team sizes, or outcomes that are not present.\n\n${position ? `Position: ${position}\n` : ''}${company ? `Company: ${company}\n` : ''}Rough input: ${text}\n\nReturn only the bullet points, one per line, each starting with "- ".`,
        maxTokens: 400,
      });
      if (text_) return text_.trim();
    } catch (error) {
      logFallback('improveExperience', error);
    }
  }
  return engine.improveExperience(payload);
};

const improveProject = async (payload) => {
  if (geminiProvider.isConfigured()) {
    try {
      const { text, name, technologies = [] } = payload;
      const result = await geminiProvider.complete({
        system: SYSTEM_PROMPT,
        prompt: `Rewrite the following rough project description into 1-3 professional sentences suitable for a resume. Use ONLY facts stated in the input or the technology list - do not invent results, users, or metrics.\n\n${name ? `Project name: ${name}\n` : ''}${technologies.length ? `Technologies: ${technologies.join(', ')}\n` : ''}Rough input: ${text}\n\nReturn only the rewritten description.`,
        maxTokens: 300,
      });
      if (result) return result.trim();
    } catch (error) {
      logFallback('improveProject', error);
    }
  }
  return engine.improveProject(payload);
};

const writeAchievement = async (payload) => {
  if (geminiProvider.isConfigured()) {
    try {
      const { text } = payload;
      const result = await geminiProvider.complete({
        system: SYSTEM_PROMPT,
        prompt: `Rewrite the following rough achievement into one concise, professional resume-ready sentence. Use ONLY facts stated - do not invent numbers or outcomes.\n\nRough input: ${text}\n\nReturn only the rewritten sentence.`,
        maxTokens: 150,
      });
      if (result) return result.trim();
    } catch (error) {
      logFallback('writeAchievement', error);
    }
  }
  return engine.writeAchievement(payload);
};

const generateCoverLetter = async (payload) => {
  if (geminiProvider.isConfigured()) {
    try {
      const { jobTitle, company, summary, experience = [], jobDescription } = payload;
      const result = await geminiProvider.complete({
        system: SYSTEM_PROMPT,
        prompt: `Write a professional cover letter using ONLY the facts below. Do not invent employers, achievements, or metrics that are not provided.\n\nJob title: ${jobTitle}\nCompany: ${company}\n${summary ? `Candidate summary: ${summary}\n` : ''}${experience.length ? `Relevant experience: ${experience.join('; ')}\n` : ''}${jobDescription ? `Job description (use only to inform tone/keywords, do not attribute claims from it to the candidate unless already listed above): ${jobDescription}\n` : ''}\nFormat: standard business letter, 3-4 paragraphs, sign off with "Sincerely,\\n[Your Name]". Return only the letter text.`,
        maxTokens: 600,
      });
      if (result) return result.trim();
    } catch (error) {
      logFallback('generateCoverLetter', error);
    }
  }
  return engine.generateCoverLetter(payload);
};

// ---------- deterministic-only features (no Gemini call) ----------

const recommendSkills = async (payload) => engine.recommendSkills(payload);

// ---------- score: deterministic core, optional Gemini narrative ----------

const scoreResume = async (payload) => {
  const localResult = engine.scoreResume(payload);
  if (!geminiProvider.isConfigured()) return localResult;
  try {
    const breakdown = {
      score: localResult.score,
      strengths: localResult.strengths,
      improvements: localResult.improvements,
      completeness: localResult.completeness,
    };
    const explanation = await geminiProvider.complete({
      system: SYSTEM_PROMPT,
      prompt: `Given this resume score breakdown (JSON), write ONE short paragraph (2-3 sentences) explaining WHY the resume scored this way, referencing the specific strengths/improvement areas listed. Do not invent new facts and do not state or imply a different score.\n\nBreakdown: ${JSON.stringify(breakdown)}\n\nReturn only the explanation paragraph.`,
      maxTokens: 220,
    });
    return explanation ? { ...localResult, explanation: explanation.trim() } : localResult;
  } catch (error) {
    logFallback('scoreResume.explanation', error);
    return localResult;
  }
};

// ---------- JD analysis ----------

const JD_ANALYSIS_SCHEMA = {
  type: 'object',
  properties: {
    role: { type: 'string' },
    seniority: { type: 'string' },
    requiredSkills: { type: 'array', items: { type: 'string' } },
    softSkills: { type: 'array', items: { type: 'string' } },
    responsibilities: { type: 'array', items: { type: 'string' } },
    educationRequirements: { type: 'array', items: { type: 'string' } },
    experienceRequirements: { type: 'array', items: { type: 'string' } },
    keywords: { type: 'array', items: { type: 'string' } },
  },
  required: ['role', 'seniority', 'requiredSkills', 'softSkills', 'responsibilities', 'educationRequirements', 'experienceRequirements', 'keywords'],
};

const analyzeJobDescription = async (payload) => {
  if (geminiProvider.isConfigured()) {
    try {
      const result = await geminiProvider.complete({
        system: SYSTEM_PROMPT,
        prompt: `Analyze the following job description and extract structured information. Only extract what is stated or clearly implied in the text - do not invent requirements.\n\nJob description:\n${payload.jobDescription}\n\nRespond with JSON matching the schema.`,
        maxTokens: 700,
        jsonSchema: JD_ANALYSIS_SCHEMA,
      });
      if (result) return result;
    } catch (error) {
      logFallback('analyzeJobDescription', error);
    }
  }
  return engine.analyzeJobDescription(payload);
};

// ---------- resume/job match: deterministic core + optional semantic add-on ----------

const matchResumeToJob = async (payload) => {
  const localResult = engine.matchResumeToJob(payload);
  const jd = (payload.jobDescription || '').toString().trim();
  if (!geminiProvider.isConfigured() || !jd) return localResult;
  try {
    const context = { overallMatch: localResult.overallMatch, skillsMatch: localResult.skillsMatch, missingSkills: localResult.missingSkills };
    const semanticAnalysis = await geminiProvider.complete({
      system: SYSTEM_PROMPT,
      prompt: `A resume was already scored against a job description using deterministic keyword/skill matching (below). Write a short semantic analysis (2-4 sentences) covering the most important gaps and strengths a recruiter would notice that simple keyword matching might miss. Do not invent facts about the candidate and do not imply a different score than the one given.\n\nDeterministic result: ${JSON.stringify(context)}\nResume summary: ${payload.summary || '(none provided)'}\nResume skills: ${(payload.skills || []).join(', ') || '(none provided)'}\nJob description: ${jd}\n\nReturn only the analysis paragraph.`,
      maxTokens: 260,
    });
    return semanticAnalysis ? { ...localResult, semanticAnalysis: semanticAnalysis.trim() } : localResult;
  } catch (error) {
    logFallback('matchResumeToJob', error);
    return localResult;
  }
};

// ---------- resume tailoring: deterministic candidate lists + optional rewrite ----------

const TAILOR_SCHEMA = {
  type: 'object',
  properties: {
    suggestedSummary: { type: 'string' },
    rewrittenBullets: {
      type: 'array',
      items: {
        type: 'object',
        properties: { original: { type: 'string' }, rewritten: { type: 'string' } },
        required: ['original', 'rewritten'],
      },
    },
  },
  required: ['suggestedSummary', 'rewrittenBullets'],
};

const tailorResume = async (payload) => {
  const localResult = engine.tailorResume(payload);
  const jd = (payload.jobDescription || '').toString().trim();
  if (!geminiProvider.isConfigured() || !jd) return { ...localResult, suggestedSummary: null, rewrittenBullets: [] };
  try {
    const aiResult = await geminiProvider.complete({
      system: SYSTEM_PROMPT,
      prompt: `Tailor resume content to a target job description WITHOUT inventing new facts.\n\nCurrent summary: ${payload.summary || '(none)'}\nBullets to emphasize - rewrite each to better align with the job description's language, using ONLY facts already present in that bullet (do not add numbers/outcomes not stated): ${JSON.stringify(localResult.bulletsToEmphasize)}\nJob description: ${jd}\n\nRespond with JSON: "suggestedSummary" (a 2-4 sentence tailored summary built only from the current summary and resume facts already given) and "rewrittenBullets" (array of {original, rewritten} for each bullet listed above, same length and order).`,
      maxTokens: 700,
      jsonSchema: TAILOR_SCHEMA,
    });
    return {
      ...localResult,
      suggestedSummary: (aiResult && aiResult.suggestedSummary) || null,
      rewrittenBullets: (aiResult && aiResult.rewrittenBullets) || [],
    };
  } catch (error) {
    logFallback('tailorResume', error);
    return { ...localResult, suggestedSummary: null, rewrittenBullets: [] };
  }
};

// ---------- resume review ----------

const REVIEW_SCHEMA = {
  type: 'object',
  properties: {
    strong: { type: 'array', items: { type: 'string' } },
    weak: { type: 'array', items: { type: 'string' } },
    missing: { type: 'array', items: { type: 'string' } },
    unclear: { type: 'array', items: { type: 'string' } },
    topPriorities: { type: 'array', items: { type: 'string' } },
  },
  required: ['strong', 'weak', 'missing', 'unclear', 'topPriorities'],
};

const reviewResume = async (payload) => {
  const localResult = engine.reviewResume(payload);
  if (!geminiProvider.isConfigured()) return localResult;
  try {
    const aiResult = await geminiProvider.complete({
      system: SYSTEM_PROMPT,
      prompt: `Review this resume and give constructive, actionable feedback grounded in the actual content given - do not invent facts about the candidate. A local deterministic analysis already found:\n${JSON.stringify(localResult)}\n\nFull resume data (JSON): ${JSON.stringify(payload)}\n\nRespond with JSON: "strong" (genuinely strong points), "weak" (weak points), "missing" (what's missing), "unclear" (vague/generic statements lacking specifics), "topPriorities" (the 3 most important fixes, ordered by priority).`,
      maxTokens: 700,
      jsonSchema: REVIEW_SCHEMA,
    });
    if (aiResult) return aiResult;
  } catch (error) {
    logFallback('reviewResume', error);
  }
  return localResult;
};

// ---------- career insights ----------

const CAREER_SCHEMA = {
  type: 'object',
  properties: {
    suitableRoles: { type: 'array', items: { type: 'string' } },
    skillsToStrengthen: { type: 'array', items: { type: 'string' } },
    missingCommonSkills: { type: 'array', items: { type: 'string' } },
    learningPriorities: { type: 'array', items: { type: 'string' } },
    resumeImprovementPriorities: { type: 'array', items: { type: 'string' } },
  },
  required: ['suitableRoles', 'skillsToStrengthen', 'missingCommonSkills', 'learningPriorities', 'resumeImprovementPriorities'],
};

const careerInsights = async (payload) => {
  const localResult = engine.careerInsights(payload);
  if (!geminiProvider.isConfigured()) return localResult;
  try {
    const aiResult = await geminiProvider.complete({
      system: SYSTEM_PROMPT,
      prompt: `Based on this resume${payload.targetRole ? ` and target role "${payload.targetRole}"` : ''}, give career recommendations. These are advisory recommendations, not guarantees - phrase them that way. A local skill-cluster analysis already found:\n${JSON.stringify(localResult)}\n\nResume data: ${JSON.stringify({ summary: payload.summary, experience: payload.experience, skills: payload.skills, projects: payload.projects })}\n\nRespond with JSON: "suitableRoles", "skillsToStrengthen", "missingCommonSkills" (common skills for these roles the candidate doesn't show), "learningPriorities" (top 3), "resumeImprovementPriorities" (top 3).`,
      maxTokens: 600,
      jsonSchema: CAREER_SCHEMA,
    });
    if (aiResult) return aiResult;
  } catch (error) {
    logFallback('careerInsights', error);
  }
  return localResult;
};

// ---------- interview prep ----------

const INTERVIEW_SCHEMA = {
  type: 'object',
  properties: {
    generalQuestions: { type: 'array', items: { type: 'string' } },
    projectQuestions: { type: 'array', items: { type: 'string' } },
    technologyQuestions: { type: 'array', items: { type: 'string' } },
    behavioralQuestions: { type: 'array', items: { type: 'string' } },
    preparationTopics: { type: 'array', items: { type: 'string' } },
  },
  required: ['generalQuestions', 'projectQuestions', 'technologyQuestions', 'behavioralQuestions', 'preparationTopics'],
};

const interviewPrep = async (payload) => {
  const localResult = engine.interviewPrep(payload);
  if (!geminiProvider.isConfigured()) return localResult;
  try {
    const aiResult = await geminiProvider.complete({
      system: SYSTEM_PROMPT,
      prompt: `Generate interview preparation material for this candidate${payload.jobDescription ? ' for the job description below' : ''}. Base project/technology questions on the candidate's actual listed projects/technologies/experience - do not invent facts about them. Never claim to predict the exact interview.\n\nResume data: ${JSON.stringify({ experience: payload.experience, projects: payload.projects, skills: payload.skills })}\n${payload.jobDescription ? `Job description: ${payload.jobDescription}\n` : ''}\nRespond with JSON: "generalQuestions", "projectQuestions" (specific to their listed projects), "technologyQuestions" (specific to their listed skills/tech), "behavioralQuestions", "preparationTopics" (topics to review beforehand).`,
      maxTokens: 700,
      jsonSchema: INTERVIEW_SCHEMA,
    });
    if (aiResult) return aiResult;
  } catch (error) {
    logFallback('interviewPrep', error);
  }
  return localResult;
};

module.exports = {
  generateSummary,
  improveExperience,
  improveProject,
  writeAchievement,
  recommendSkills,
  scoreResume,
  generateCoverLetter,
  analyzeJobDescription,
  matchResumeToJob,
  tailorResume,
  reviewResume,
  careerInsights,
  interviewPrep,
};
