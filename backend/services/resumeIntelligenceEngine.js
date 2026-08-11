// Zero-cost, deterministic Resume Intelligence Engine.
//
// This replaces the previous Anthropic-backed prompt/response logic with
// rule-based algorithms and structured templates. Every function here only
// rephrases, scores, or recombines facts the caller actually provided - none
// of them invent employers, dates, metrics, or skills that weren't given.
// No network calls, no API key, no external dependency.

const { SKILL_CLUSTERS } = require('../data/skillTaxonomy');
const { WEAK_OPENER_REPLACEMENTS, FILLER_WORDS, QUANTIFICATION_PATTERN, GERUND_TO_PAST, STOPWORDS } = require('../data/writingRules');

// ---------- generic text helpers ----------

const capitalize = (str) => (str ? str.charAt(0).toUpperCase() + str.slice(1) : str);

const collapseWhitespace = (str) => str.replace(/\s+/g, ' ').trim();

const ensureTrailingPeriod = (str) => (/[.!?]$/.test(str) ? str : `${str}.`);

const tidySentence = (str) => {
  let s = collapseWhitespace(str || '');
  if (!s) return s;
  s = capitalize(s);
  return ensureTrailingPeriod(s);
};

const dedupeStrings = (arr) => {
  const seen = new Set();
  const out = [];
  for (const item of arr) {
    const trimmed = (item || '').toString().trim();
    if (!trimmed) continue;
    const key = trimmed.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(trimmed);
  }
  return out;
};

const formatList = (items) => {
  const list = items.filter(Boolean);
  if (list.length === 0) return '';
  if (list.length === 1) return list[0];
  if (list.length === 2) return `${list[0]} and ${list[1]}`;
  return `${list.slice(0, -1).join(', ')}, and ${list[list.length - 1]}`;
};

// Converts a leading gerund ("deploying") to past tense ("Deployed"), used
// when a weak opener is immediately followed by one (see below). Returns
// null if the word doesn't look like a gerund the naive rule can handle.
const gerundToPast = (word) => {
  const lower = word.toLowerCase();
  if (GERUND_TO_PAST[lower]) return GERUND_TO_PAST[lower];
  if (lower.endsWith('ying') && lower.length > 4) {
    const stem = lower.slice(0, -4);
    const precedingVowel = 'aeiou'.includes(stem.slice(-1));
    // consonant+y ("apply" -> "applied") vs vowel+y ("deploy" -> "deployed")
    return capitalize(precedingVowel ? `${stem}yed` : `${stem}ied`);
  }
  if (lower.endsWith('ing') && lower.length > 4) return capitalize(`${lower.slice(0, -3)}ed`);
  return null;
};

// Replaces a weak/passive opening phrase with a strong action verb. Only
// rewrites the opener - the rest of the sentence (the actual claim) is left
// exactly as the user wrote it. If the opener is immediately followed by a
// gerund ("worked on deploying..."), the gerund is converted to past tense
// instead of prepending a verb before it ("Deployed..." rather than the
// grammatically awkward "Developed deploying...").
const applyOpenerReplacement = (sentence) => {
  const lower = sentence.toLowerCase();
  for (const [weak, strong] of WEAK_OPENER_REPLACEMENTS) {
    if (lower.startsWith(weak)) {
      const rest = sentence.slice(weak.length);
      const trimmedRest = rest.replace(/^\s+/, '');
      const firstWordMatch = trimmedRest.match(/^([A-Za-z]+)(\s|$)/);
      if (firstWordMatch && firstWordMatch[1].toLowerCase().endsWith('ing')) {
        const pastVerb = gerundToPast(firstWordMatch[1]);
        if (pastVerb) {
          const remainder = trimmedRest.slice(firstWordMatch[1].length);
          return `${pastVerb}${remainder}`;
        }
      }
      return `${strong}${rest}`;
    }
  }
  return sentence;
};

const hasWeakOpener = (sentence) => {
  const lower = sentence.toLowerCase();
  return WEAK_OPENER_REPLACEMENTS.some(([weak]) => lower.startsWith(weak));
};

const stripFillerWords = (text) => {
  let result = text;
  for (const filler of FILLER_WORDS) {
    const pattern = new RegExp(`\\b${filler.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b`, 'gi');
    result = result.replace(pattern, '');
  }
  return collapseWhitespace(result);
};

// Splits free-form input text into individual bullet/sentence candidates,
// handling text that already uses "- "/"• " markers or newlines, or plain
// sentence-separated prose.
const splitIntoLines = (text) => {
  const raw = (text || '').trim();
  if (!raw) return [];

  const byNewline = raw.split(/\r?\n/).map((l) => l.replace(/^[-•*]\s*/, '').trim()).filter(Boolean);
  if (byNewline.length > 1) return byNewline;

  const bySentence = raw
    .split(/(?<=[.!?])\s+/)
    .map((l) => l.replace(/^[-•*]\s*/, '').trim())
    .filter(Boolean);
  return bySentence.length ? bySentence : [raw];
};

const transformLine = (line) => {
  let result = collapseWhitespace(line);
  result = applyOpenerReplacement(result);
  result = stripFillerWords(result);
  result = capitalize(result);
  return result;
};

const hasQuantification = (text) => QUANTIFICATION_PATTERN.test(text || '');

// Flattens an arbitrary section-item object (unknown field names, since
// resume sections store freeform key/value data) into one search/scoring
// text blob, one level deep into nested arrays/objects.
const flattenObjectText = (obj, depth = 0) => {
  if (obj == null) return '';
  if (typeof obj === 'string') return obj;
  if (typeof obj === 'number' || typeof obj === 'boolean') return String(obj);
  if (depth >= 2) return '';
  if (Array.isArray(obj)) return obj.map((v) => flattenObjectText(v, depth + 1)).join(' ');
  if (typeof obj === 'object') return Object.values(obj).map((v) => flattenObjectText(v, depth + 1)).join(' ');
  return '';
};

const flattenObjectArrayText = (arr) => (arr || []).map((o) => flattenObjectText(o)).join(' ');

// Plain substring matching false-positives badly on short skill names (e.g.
// "R" matching inside "React", "AWS", or any word containing the letter r).
// This checks the characters immediately surrounding a match aren't
// alphanumeric, so only a true whole-word/whole-phrase match counts -
// without the \b regex quirks that come with skill names containing
// characters like "#"/"+"/"." (C#, .NET, C++).
const containsWholeWord = (haystack, needle) => {
  if (!needle) return false;
  const isWordChar = (c) => /[a-z0-9]/i.test(c || '');
  let fromIndex = 0;
  while (true) {
    const idx = haystack.indexOf(needle, fromIndex);
    if (idx === -1) return false;
    const before = idx > 0 ? haystack[idx - 1] : '';
    const after = idx + needle.length < haystack.length ? haystack[idx + needle.length] : '';
    if (!isWordChar(before) && !isWordChar(after)) return true;
    fromIndex = idx + 1;
  }
};

// ---------- 1. generateSummary ----------

const generateSummary = ({ currentSummary, experience = [], skills = [], education = [] }) => {
  const role = (experience[0]?.position || '').toString().trim();
  const topSkills = dedupeStrings(skills).slice(0, 5);
  const topEducation = education[0];
  const degree = topEducation?.degree ? topEducation.degree.toString().trim() : '';
  const institution = topEducation?.institution ? topEducation.institution.toString().trim() : '';

  if (currentSummary && currentSummary.toString().trim()) {
    let base = tidySentence(currentSummary.toString());
    if (topSkills.length && !topSkills.some((s) => containsWholeWord(base.toLowerCase(), s.toLowerCase()))) {
      base += ` Skilled in ${formatList(topSkills)}.`;
    }
    return base;
  }

  const sentences = [];
  if (role && topSkills.length) {
    sentences.push(`${role} with hands-on experience in ${formatList(topSkills)}.`);
  } else if (role) {
    sentences.push(`${role} focused on delivering high-quality, reliable work.`);
  } else if (topSkills.length) {
    sentences.push(`Motivated professional skilled in ${formatList(topSkills)}.`);
  } else if (degree || institution) {
    sentences.push(`${degree || 'Graduate'}${institution ? ` from ${institution}` : ''}.`);
  } else {
    sentences.push('Dedicated professional eager to contribute skills and experience to a new role.');
  }

  if ((degree || institution) && role) {
    sentences.push(`Holds a ${degree || 'degree'}${institution ? ` from ${institution}` : ''}.`);
  }

  if (experience.length > 1) {
    const companies = dedupeStrings(experience.map((e) => e.company)).slice(0, 3);
    if (companies.length) {
      sentences.push(`Experience spans roles at ${formatList(companies)}.`);
    }
  }

  return sentences.join(' ');
};

// ---------- 2. improveExperience ----------

const improveExperience = ({ text }) => {
  const lines = splitIntoLines(text).map(transformLine).filter(Boolean);
  const bullets = (lines.length ? lines : [tidySentence(text)]).slice(0, 4);
  return bullets.map((b) => `- ${b.replace(/\.$/, '')}`).join('\n');
};

// ---------- 3. improveProject ----------

const improveProject = ({ text, technologies = [] }) => {
  const lines = splitIntoLines(text).map(transformLine).map(tidySentence).filter(Boolean);
  const sentences = (lines.length ? lines : [tidySentence(text)]).slice(0, 3);

  const combined = sentences.join(' ');
  const lowerCombined = combined.toLowerCase();
  const unmentionedTech = dedupeStrings(technologies).filter((t) => !containsWholeWord(lowerCombined, t.toLowerCase()));
  if (unmentionedTech.length) {
    sentences.push(tidySentence(`Built using ${formatList(unmentionedTech)}`));
  }

  return sentences.join(' ');
};

// ---------- 4. recommendSkills ----------

const recommendSkills = ({ summary = '', experience = [], existingSkills = [] }) => {
  const combinedText = `${summary || ''} ${(experience || []).join(' ')}`.toLowerCase();
  const existingLower = new Set(dedupeStrings(existingSkills).map((s) => s.toLowerCase()));

  const clusterHits = SKILL_CLUSTERS.map((cluster) => ({
    cluster,
    hitCount: cluster.skills.filter((skill) => containsWholeWord(combinedText, skill.toLowerCase())).length,
  })).sort((a, b) => b.hitCount - a.hitCount);

  const fallbackCluster = SKILL_CLUSTERS.find((c) => c.key === 'general_professional');
  const relevantClusters = clusterHits.filter((c) => c.hitCount > 0).slice(0, 2).map((c) => c.cluster);
  const candidateClusters = relevantClusters.length ? relevantClusters : [fallbackCluster];

  const seen = new Set(existingLower);
  const recommendations = [];

  const collectFrom = (cluster) => {
    if (!cluster) return;
    for (const skill of cluster.skills) {
      if (recommendations.length >= 8) return;
      const lower = skill.toLowerCase();
      if (seen.has(lower) || containsWholeWord(combinedText, lower)) continue;
      seen.add(lower);
      recommendations.push(skill);
    }
  };

  candidateClusters.forEach(collectFrom);
  if (recommendations.length < 5 && !candidateClusters.includes(fallbackCluster)) {
    collectFrom(fallbackCluster);
  }

  return recommendations.slice(0, 8);
};

// ---------- 5. scoreResume (+ completeness + optional keyword match) ----------

const scoreSection = (weight, ratio) => Math.round(weight * Math.max(0, Math.min(1, ratio)));

const scoreResume = ({ summary = '', experience = [], education = [], skills = [], projects = [], jobDescription = '' }) => {
  const summaryText = (summary || '').toString();
  const expText = flattenObjectArrayText(experience);
  const projText = flattenObjectArrayText(projects);
  const allBulletsText = `${expText} ${projText}`;

  const strengths = [];
  const improvements = [];
  const breakdown = {};

  // 1. Summary quality (15)
  if (summaryText.length >= 50) {
    breakdown.summary = 15;
    strengths.push('Includes a clear, sufficiently detailed professional summary.');
  } else if (summaryText.length > 0) {
    breakdown.summary = 8;
    improvements.push('Expand your professional summary with more detail (aim for at least 2-3 sentences).');
  } else {
    breakdown.summary = 0;
    improvements.push('Add a professional summary to quickly highlight your value proposition.');
  }

  // 2. Experience presence & depth (20)
  const expWithDescription = experience.filter((e) => flattenObjectText(e).length >= 30).length;
  if (experience.length >= 2 && expWithDescription >= 2) {
    breakdown.experience = 20;
    strengths.push('Work experience section includes multiple detailed entries.');
  } else if (experience.length >= 1 && expWithDescription >= 1) {
    breakdown.experience = 12;
  } else if (experience.length >= 1) {
    breakdown.experience = 5;
    improvements.push('Add descriptions to your experience entries, not just titles and dates.');
  } else {
    breakdown.experience = 0;
    improvements.push('Add at least one work experience entry.');
  }

  // 3. Quantified achievements (15)
  if (hasQuantification(allBulletsText)) {
    breakdown.quantification = 15;
    strengths.push('Experience/project descriptions include measurable, quantified results.');
  } else {
    breakdown.quantification = 0;
    if (experience.length || projects.length) {
      improvements.push('Add specific numbers to your bullet points (e.g., percentages, counts, dollar amounts, team size).');
    }
  }

  // 4. Skills breadth (15)
  const skillCount = dedupeStrings(skills).length;
  if (skillCount >= 8) {
    breakdown.skills = 15;
    strengths.push('Skills section is broad and detailed.');
  } else if (skillCount >= 4) {
    breakdown.skills = 10;
  } else if (skillCount >= 1) {
    breakdown.skills = 5;
    improvements.push('Expand your skills list - aim for at least 5-8 relevant skills.');
  } else {
    breakdown.skills = 0;
    improvements.push('Add a skills section listing your relevant technical and professional skills.');
  }

  // 5. Education presence (10)
  if (education.length >= 1) {
    breakdown.education = 10;
  } else {
    breakdown.education = 0;
    improvements.push('Add an education entry.');
  }

  // 6. Projects (10)
  const projWithDescription = projects.filter((p) => flattenObjectText(p).length >= 20).length;
  if (projWithDescription >= 1) {
    breakdown.projects = 10;
    strengths.push('Includes relevant projects that demonstrate applied experience.');
  } else if (projects.length >= 1) {
    breakdown.projects = 5;
  } else {
    breakdown.projects = 0;
    improvements.push('Consider adding 1-2 projects to demonstrate applied experience.');
  }

  // 7. Action-verb strength (10)
  const bulletLines = [
    ...splitIntoLines(expText),
    ...splitIntoLines(projText),
  ].filter((l) => l.length >= 8);
  if (bulletLines.length) {
    const weakCount = bulletLines.filter(hasWeakOpener).length;
    const strongRatio = 1 - weakCount / bulletLines.length;
    breakdown.actionVerbs = scoreSection(10, strongRatio);
    if (strongRatio >= 0.8) {
      strengths.push('Bullet points consistently use strong, active phrasing.');
    } else if (weakCount > 0) {
      improvements.push('Rewrite passive phrases like "responsible for" or "helped with" using strong action verbs (e.g., Led, Built, Managed).');
    }
  } else {
    breakdown.actionVerbs = 0;
  }

  // 8. Overall content depth / ATS-friendliness (5)
  const totalContentLength = summaryText.length + allBulletsText.length;
  breakdown.contentDepth = scoreSection(5, totalContentLength / 400);

  const score = Object.values(breakdown).reduce((a, b) => a + b, 0);

  // Completeness: which major resume sections are actually filled in.
  const sectionPresence = {
    summary: summaryText.trim().length > 0,
    experience: experience.length > 0,
    education: education.length > 0,
    skills: skills.length > 0,
    projects: projects.length > 0,
  };
  const presentCount = Object.values(sectionPresence).filter(Boolean).length;
  const missingSections = Object.entries(sectionPresence).filter(([, present]) => !present).map(([key]) => key);
  const completeness = {
    percent: Math.round((presentCount / Object.keys(sectionPresence).length) * 100),
    missingSections,
  };

  const result = {
    score: Math.max(0, Math.min(100, score)),
    strengths: strengths.slice(0, 4),
    improvements: improvements.slice(0, 4),
    completeness,
  };

  const jd = (jobDescription || '').toString().trim();
  if (jd) {
    result.keywordMatch = matchJobDescriptionKeywords(jd, { summary: summaryText, skills, experience, projects });
  }

  return result;
};

// ---------- 2 (continued). Job-description keyword matching ----------

// Special characters (# + .) are only meaningful for whole-phrase skill
// matching (done separately below, against the raw un-tokenized text), so
// this generic word-frequency pass strips all punctuation - avoiding
// trailing-punctuation artifacts like "kubernetes." becoming its own token.
const tokenize = (text) =>
  (text || '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .split(/\s+/)
    .filter((w) => w.length >= 3 && !STOPWORDS.has(w));

const extractKeywords = (jobDescription, maxKeywords = 20) => {
  const lowerJd = jobDescription.toLowerCase();
  const allSkills = dedupeStrings(SKILL_CLUSTERS.flatMap((c) => c.skills));
  const skillHits = allSkills.filter((skill) => containsWholeWord(lowerJd, skill.toLowerCase()));

  const tokens = tokenize(jobDescription);
  const freq = new Map();
  for (const t of tokens) freq.set(t, (freq.get(t) || 0) + 1);
  const topTokens = [...freq.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([word]) => word)
    .filter((word) => !skillHits.some((skill) => containsWholeWord(skill.toLowerCase(), word)));

  const keywords = dedupeStrings([...skillHits, ...topTokens]);
  return keywords.slice(0, maxKeywords);
};

const matchJobDescriptionKeywords = (jobDescription, resumeData) => {
  const keywords = extractKeywords(jobDescription);
  const resumeText = [
    resumeData.summary,
    (resumeData.skills || []).join(' '),
    flattenObjectArrayText(resumeData.experience),
    flattenObjectArrayText(resumeData.projects),
  ].join(' ').toLowerCase();

  const matched = keywords.filter((k) => containsWholeWord(resumeText, k.toLowerCase()));
  const missing = keywords.filter((k) => !matched.includes(k));
  const matchPercentage = keywords.length ? Math.round((matched.length / keywords.length) * 100) : 0;

  return { matched, missing, matchPercentage };
};

// ---------- 7. generateCoverLetter ----------

const generateCoverLetter = ({ jobTitle, company, summary, experience = [] }) => {
  const paragraphs = [];

  let opening = `I am writing to express my interest in the ${jobTitle} position at ${company}.`;
  if (summary && summary.toString().trim()) {
    opening += ` ${tidySentence(summary.toString())}`;
  }
  paragraphs.push(opening);

  const expList = dedupeStrings(experience);
  if (expList.length) {
    paragraphs.push(`My relevant experience includes: ${formatList(expList)}.`);
  }

  paragraphs.push(
    `I am confident that my background aligns well with the requirements of this role, and I would welcome the opportunity to discuss how I can contribute to ${company}.`
  );

  paragraphs.push('Thank you for considering my application. I look forward to the opportunity to speak with you further.\n\nSincerely,\n[Your Name]');

  return `Dear Hiring Manager,\n\n${paragraphs.join('\n\n')}`;
};

// ---------- 8. writeAchievement ----------

const writeAchievement = ({ text }) => {
  const lines = splitIntoLines(text).map(transformLine).map(tidySentence).filter(Boolean);
  return lines[0] || tidySentence(text || '');
};

// ---------- 9. analyzeJobDescription ----------

const SOFT_SKILLS = [
  'communication', 'teamwork', 'collaboration', 'leadership', 'problem solving', 'problem-solving',
  'adaptability', 'time management', 'critical thinking', 'creativity', 'attention to detail',
  'organization', 'work ethic', 'interpersonal skills', 'conflict resolution', 'decision making',
  'mentoring', 'ownership', 'self-motivated', 'multitasking',
];

// Checked in priority order, most-senior first: a JD titled "Senior Engineer"
// that also happens to mention "mentoring junior engineers" is a senior role,
// not an entry-level one - so higher-seniority terms must win over "junior"
// appearing incidentally (as a subordinate/mentee reference) elsewhere in the
// text, rather than the first pattern encountered winning regardless of rank.
const SENIORITY_PATTERNS = [
  { pattern: /\b(manager|head of|director|vp\b|vice president)\b/i, label: 'Management' },
  { pattern: /\b(lead|principal|staff)\b/i, label: 'Lead / Principal' },
  { pattern: /\b(senior|sr\.)\b/i, label: 'Senior' },
  { pattern: /\b(intern|internship)\b/i, label: 'Internship' },
  { pattern: /\b(mid.level|intermediate)\b/i, label: 'Mid-level' },
  { pattern: /\b(entry.level|junior|associate)\b/i, label: 'Entry-level / Junior' },
];

const detectSeniority = (jd) => {
  for (const { pattern, label } of SENIORITY_PATTERNS) {
    if (pattern.test(jd)) return label;
  }
  const yearsMatch = jd.match(/(\d+)\+?\s*(?:to\s*\d+\s*)?years?/i);
  if (yearsMatch) {
    const years = parseInt(yearsMatch[1], 10);
    if (years >= 7) return 'Senior';
    if (years >= 3) return 'Mid-level';
    return 'Entry-level / Junior';
  }
  return 'Not specified';
};

const detectRoleTitle = (jd) => {
  const lines = splitIntoLines(jd);
  const titleLine = lines.find((l) => /title\s*:/i.test(l));
  if (titleLine) return titleLine.replace(/.*title\s*:/i, '').trim().slice(0, 100);
  return lines[0] ? lines[0].slice(0, 100) : 'Not specified';
};

const extractRequirementLines = (jd) => {
  const lines = splitIntoLines(jd);
  const reqKeywords = /\b(require|must have|should have|need|minimum|experience with|proficien|familiar with|ability to)\b/i;
  return lines.filter((l) => reqKeywords.test(l) && l.length <= 300).slice(0, 10);
};

const analyzeJobDescription = ({ jobDescription = '' }) => {
  const jd = (jobDescription || '').toString().trim();
  if (!jd) {
    return {
      role: '', seniority: 'Not specified', requiredSkills: [], softSkills: [],
      responsibilities: [], educationRequirements: [], experienceRequirements: [], keywords: [],
    };
  }
  const lowerJd = jd.toLowerCase();
  const requiredSkills = extractKeywords(jd, 15).filter((k) =>
    SKILL_CLUSTERS.some((c) => c.skills.some((s) => s.toLowerCase() === k.toLowerCase()))
  );
  const softSkills = dedupeStrings(SOFT_SKILLS.filter((s) => containsWholeWord(lowerJd, s)).map(capitalize));
  const responsibilities = splitIntoLines(jd).filter((l) => /\b(responsib|you will|duties|role involves)\b/i.test(l)).slice(0, 8);
  const educationRequirements = splitIntoLines(jd).filter((l) => /\b(degree|bachelor|master|b\.?s\.?|m\.?s\.?|diploma)\b/i.test(l)).slice(0, 5);

  return {
    role: detectRoleTitle(jd),
    seniority: detectSeniority(jd),
    requiredSkills,
    softSkills,
    responsibilities,
    educationRequirements,
    experienceRequirements: extractRequirementLines(jd),
    keywords: extractKeywords(jd, 20),
  };
};

// ---------- 10. matchResumeToJob ----------

const matchResumeToJob = ({ summary = '', experience = [], education = [], skills = [], projects = [], jobDescription = '' }) => {
  const jd = (jobDescription || '').toString().trim();
  if (!jd) {
    return {
      overallMatch: 0,
      keywordMatch: { matched: [], missing: [], matchPercentage: 0 },
      skillsMatch: 0,
      experienceRelevance: 0,
      educationRelevance: 0,
      missingSkills: [],
      recommendations: ['Paste a job description to see how your resume matches.'],
    };
  }

  const keywordMatch = matchJobDescriptionKeywords(jd, { summary, skills, experience, projects });

  const jdSkills = extractKeywords(jd, 25).filter((k) =>
    SKILL_CLUSTERS.some((c) => c.skills.some((s) => s.toLowerCase() === k.toLowerCase()))
  );
  const existingLower = dedupeStrings(skills).map((s) => s.toLowerCase());
  const skillsMatched = jdSkills.filter((s) => existingLower.includes(s.toLowerCase()));
  const skillsMatch = jdSkills.length
    ? Math.round((skillsMatched.length / jdSkills.length) * 100)
    : (existingLower.length ? 50 : 0);

  const jdTokens = dedupeStrings(tokenize(jd));
  const expText = flattenObjectArrayText(experience).toLowerCase();
  const experienceRelevance = jdTokens.length
    ? Math.round((jdTokens.filter((t) => expText.includes(t)).length / jdTokens.length) * 100)
    : 0;

  const eduText = flattenObjectArrayText(education).toLowerCase();
  const educationRelevance = education.length
    ? (jdTokens.length ? Math.round((jdTokens.filter((t) => eduText.includes(t)).length / jdTokens.length) * 100) : 40)
    : 0;

  const missingSkills = jdSkills.filter((s) => !existingLower.includes(s.toLowerCase())).slice(0, 10);

  const overallMatch = Math.round(
    keywordMatch.matchPercentage * 0.4 + skillsMatch * 0.3 + experienceRelevance * 0.2 + educationRelevance * 0.1
  );

  const recommendations = [];
  if (missingSkills.length) recommendations.push(`Consider highlighting or developing: ${formatList(missingSkills.slice(0, 5))}.`);
  if (keywordMatch.missing.length) recommendations.push(`Incorporate relevant keywords if truthful: ${formatList(keywordMatch.missing.slice(0, 5))}.`);
  if (!summaryHasContent(summary)) recommendations.push('Add a professional summary tailored to this role.');

  return {
    overallMatch: Math.max(0, Math.min(100, overallMatch)),
    keywordMatch,
    skillsMatch,
    experienceRelevance,
    educationRelevance,
    missingSkills,
    recommendations: recommendations.slice(0, 5),
  };
};

const summaryHasContent = (summary) => Boolean((summary || '').toString().trim());

// ---------- 11. tailorResume ----------

const tailorResume = ({ summary = '', experience = [], projects = [], skills = [], jobDescription = '' }) => {
  const jd = (jobDescription || '').toString().trim();
  if (!jd) {
    return {
      skillsToHighlight: [], bulletsToEmphasize: [], projectsToEmphasize: [],
      keywordsToIncorporate: [], sectionsNeedingImprovement: ['Add a job description to get tailored suggestions.'],
    };
  }

  const jdLower = jd.toLowerCase();
  const jdTokens = tokenize(jd);
  const skillsToHighlight = dedupeStrings(skills).filter((s) => containsWholeWord(jdLower, s.toLowerCase()));

  const bulletsToEmphasize = experience
    .flatMap((e) => splitIntoLines(flattenObjectText(e)))
    .filter((b) => b.length >= 15 && jdTokens.some((t) => b.toLowerCase().includes(t)))
    .slice(0, 6);

  const projectsToEmphasize = projects
    .filter((p) => jdTokens.some((t) => flattenObjectText(p).toLowerCase().includes(t)))
    .map((p) => p.name || p.title || flattenObjectText(p).slice(0, 60))
    .filter(Boolean)
    .slice(0, 4);

  const keywordMatch = matchJobDescriptionKeywords(jd, { summary, skills, experience, projects });
  const scoreResult = scoreResume({ summary, experience, projects, skills, jobDescription: jd });

  return {
    skillsToHighlight: skillsToHighlight.slice(0, 10),
    bulletsToEmphasize,
    projectsToEmphasize,
    keywordsToIncorporate: keywordMatch.missing.slice(0, 8),
    sectionsNeedingImprovement: scoreResult.improvements,
  };
};

// ---------- 12. reviewResume ----------

const reviewResume = (payload) => {
  const result = scoreResume(payload);
  return {
    strong: result.strengths,
    weak: result.improvements.slice(0, 3),
    missing: result.completeness.missingSections.map((s) => `Missing ${s} section.`),
    unclear: [],
    topPriorities: result.improvements.slice(0, 3),
  };
};

// ---------- 13. careerInsights ----------

const ROLE_LABELS = {
  frontend: 'Frontend Developer',
  backend: 'Backend Developer',
  data: 'Data Analyst / Data Scientist',
  mobile: 'Mobile App Developer',
  devops: 'DevOps / Site Reliability Engineer',
  design: 'UI/UX Designer',
  product_business: 'Product / Business Analyst',
  general_professional: 'General Professional Roles',
};

const careerInsights = ({ summary = '', experience = [], skills = [], projects = [] }) => {
  const combinedText = `${summary} ${flattenObjectArrayText(experience)} ${flattenObjectArrayText(projects)}`.toLowerCase();
  const existingLower = new Set(dedupeStrings(skills).map((s) => s.toLowerCase()));

  const clusterHits = SKILL_CLUSTERS.map((cluster) => ({
    cluster,
    hitCount: cluster.skills.filter((s) => existingLower.has(s.toLowerCase()) || containsWholeWord(combinedText, s.toLowerCase())).length,
  })).sort((a, b) => b.hitCount - a.hitCount);

  const topClusters = clusterHits.filter((c) => c.hitCount > 0).slice(0, 3);
  const suitableRoles = topClusters.length
    ? topClusters.map((c) => ROLE_LABELS[c.cluster.key] || c.cluster.key)
    : ['General Professional Roles'];

  const skillsToStrengthen = [];
  topClusters.forEach(({ cluster }) => {
    cluster.skills.forEach((s) => {
      if (skillsToStrengthen.length >= 8) return;
      if (!existingLower.has(s.toLowerCase())) skillsToStrengthen.push(s);
    });
  });

  const scoreResult = scoreResume({ summary, experience, skills, projects });

  return {
    suitableRoles,
    skillsToStrengthen: dedupeStrings(skillsToStrengthen).slice(0, 8),
    missingCommonSkills: dedupeStrings(skillsToStrengthen).slice(0, 5),
    learningPriorities: dedupeStrings(skillsToStrengthen).slice(0, 3),
    resumeImprovementPriorities: scoreResult.improvements.slice(0, 3),
  };
};

// ---------- 14. interviewPrep ----------

const BEHAVIORAL_QUESTIONS = [
  'Tell me about a time you faced a challenging technical problem. How did you approach it?',
  'Describe a situation where you had to work with a difficult team member.',
  'Tell me about a time you missed a deadline or made a mistake. What did you learn?',
  'Describe a time you had to learn a new technology quickly.',
  'Tell me about a time you disagreed with a decision at work or in a project. How did you handle it?',
];

const interviewPrep = ({ experience = [], projects = [], skills = [] }) => {
  const generalQuestions = [
    'Walk me through your resume.',
    'Why are you interested in this role?',
    'What are your greatest strengths and weaknesses?',
  ];

  const projectQuestions = projects.slice(0, 5).map((p) => {
    const name = p.name || p.title || 'this project';
    return `Walk me through the "${name}" project - what was your specific contribution and what challenges did you face?`;
  });

  const experienceQuestions = experience.slice(0, 4).map((e) => {
    const position = e.position || e.title || 'your role';
    const company = e.company ? ` at ${e.company}` : '';
    return `Tell me about your responsibilities as ${position}${company}.`;
  });

  const techSet = dedupeStrings([...skills, ...projects.flatMap((p) => p.technologies || [])]).slice(0, 8);
  const technologyQuestions = techSet.map((t) => `How have you used ${t} in your work, and what is your proficiency level?`);

  const preparationTopics = dedupeStrings([
    ...techSet,
    ...experience.map((e) => e.position || e.title).filter(Boolean),
  ]).slice(0, 10);

  return {
    generalQuestions,
    projectQuestions: [...projectQuestions, ...experienceQuestions].slice(0, 8),
    technologyQuestions,
    behavioralQuestions: BEHAVIORAL_QUESTIONS,
    preparationTopics,
  };
};

module.exports = {
  generateSummary,
  improveExperience,
  improveProject,
  recommendSkills,
  scoreResume,
  generateCoverLetter,
  writeAchievement,
  analyzeJobDescription,
  matchResumeToJob,
  tailorResume,
  reviewResume,
  careerInsights,
  interviewPrep,
  // Exported for direct unit testing, not used outside this module otherwise.
  containsWholeWord,
  extractKeywords,
};
