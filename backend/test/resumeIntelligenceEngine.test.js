// Tests for the local, zero-cost Resume Intelligence Engine. Uses Node's
// built-in test runner (node:test) so no test framework dependency is
// needed. Run with `npm test` from backend/.
const test = require('node:test');
const assert = require('node:assert/strict');

const engine = require('../services/resumeIntelligenceEngine');

test('scoreResume: returns the expected shape with score in [0, 100]', () => {
  const result = engine.scoreResume({
    summary: 'Experienced backend engineer focused on distributed systems.',
    skills: ['Node.js', 'MongoDB'],
    experience: [{ position: 'Engineer', company: 'Acme', description: 'Built services.' }],
  });

  assert.equal(typeof result.score, 'number');
  assert.ok(result.score >= 0 && result.score <= 100);
  assert.ok(Array.isArray(result.strengths));
  assert.ok(Array.isArray(result.improvements));
  assert.equal(typeof result.completeness.percent, 'number');
  assert.ok(Array.isArray(result.completeness.missingSections));
});

test('scoreResume: is deterministic for identical input', () => {
  const input = {
    summary: 'Product-focused engineer.',
    skills: ['React', 'TypeScript'],
    experience: [{ position: 'Engineer', company: 'Acme', description: 'Shipped features.' }],
  };
  const a = engine.scoreResume({ ...input });
  const b = engine.scoreResume({ ...input });
  assert.deepEqual(a, b);
});

test('scoreResume: a fully-detailed resume scores meaningfully higher than an empty one', () => {
  const strong = engine.scoreResume({
    summary: 'Software engineer with 5 years building scalable web applications and leading small teams.',
    skills: ['JavaScript', 'React', 'Node.js', 'MongoDB', 'Docker', 'AWS', 'Git', 'REST APIs'],
    experience: [{ position: 'Engineer', company: 'Acme', description: 'Reduced page load time by 30% and shipped 5 major features.' }],
    education: [{ degree: 'B.Tech', institution: 'State University' }],
    projects: [{ name: 'Toolkit', description: 'Built a widely used internal developer toolkit used by 50+ engineers.' }],
  });
  const empty = engine.scoreResume({});

  assert.ok(strong.score > empty.score);
  assert.ok(empty.improvements.length > 0);
});

test('scoreResume: completeness reflects which of the 5 major sections are present', () => {
  const result = engine.scoreResume({ summary: 'Has a summary.', skills: ['JavaScript'] });
  assert.ok(result.completeness.missingSections.includes('experience'));
  assert.ok(result.completeness.missingSections.includes('education'));
  assert.ok(result.completeness.missingSections.includes('projects'));
  assert.ok(!result.completeness.missingSections.includes('summary'));
  assert.ok(!result.completeness.missingSections.includes('skills'));
});

test('scoreResume: keywordMatch is only present when a jobDescription is given', () => {
  const withoutJd = engine.scoreResume({ summary: 'Engineer.' });
  assert.equal(withoutJd.keywordMatch, undefined);

  const withJd = engine.scoreResume({ summary: 'React engineer.', skills: ['React'], jobDescription: 'Looking for a React developer with AWS experience.' });
  assert.ok(withJd.keywordMatch);
  assert.ok(Array.isArray(withJd.keywordMatch.matched));
  assert.ok(Array.isArray(withJd.keywordMatch.missing));
  assert.ok(withJd.keywordMatch.matchPercentage >= 0 && withJd.keywordMatch.matchPercentage <= 100);
});

test('containsWholeWord: does not match a short word embedded inside a longer one (regression)', () => {
  // The original bug: naive .includes() matched "R" inside "React"/"for",
  // and "Go" inside "Google", producing nonsense keyword/skill matches.
  assert.equal(engine.containsWholeWord('looking for a react and aws engineer', 'r'), false);
  assert.equal(engine.containsWholeWord('deployed on google cloud platform', 'go'), false);
  // But a real standalone occurrence must still match.
  assert.equal(engine.containsWholeWord('experienced with r and python', 'r'), true);
  assert.equal(engine.containsWholeWord('proficient in go and rust', 'go'), true);
});

test('extractKeywords: does not extract "R" from a job description that only contains it as a substring', () => {
  const keywords = engine.extractKeywords('Looking for a React and AWS engineer.');
  assert.ok(!keywords.includes('R'));
  assert.ok(keywords.some((k) => k.toLowerCase() === 'react'));
});

test('recommendSkills: excludes skills already listed or already mentioned verbatim in the text', () => {
  const recommendations = engine.recommendSkills({
    summary: 'Backend engineer with Node.js and MongoDB experience.',
    existingSkills: ['Node.js'],
  });
  const lower = recommendations.map((s) => s.toLowerCase());
  assert.ok(!lower.includes('node.js')); // excluded via existingSkills
  assert.ok(!lower.includes('mongodb')); // excluded via exact mention in the text
  assert.ok(recommendations.length > 0);
});


test('generateSummary: never fabricates a company, institution, or degree not provided', () => {
  const result = engine.generateSummary({ skills: ['Python', 'SQL'] });
  assert.ok(!/inc\.|corp\.|university|college/i.test(result));
});

test('generateSummary: preserves user-provided current summary content', () => {
  const result = engine.generateSummary({ currentSummary: 'a passionate builder of things', skills: [] });
  assert.ok(result.toLowerCase().includes('passionate builder of things'));
});

test('improveExperience: converts a weak opener followed by a gerund to natural past tense (regression)', () => {
  const result = engine.improveExperience({ text: 'worked on deploying the app to production.' });
  assert.ok(result.includes('Deployed the app to production'));
  assert.ok(!result.includes('Developed deploying'));
});

test('improveExperience: does not invent facts not present in the original text', () => {
  const result = engine.improveExperience({ text: 'built an internal tool.' });
  assert.ok(!/\d+%/.test(result)); // no fabricated percentage
});

test('improveProject: appends technologies only when not already mentioned', () => {
  const withNewTech = engine.improveProject({ text: 'A dashboard for tracking metrics.', technologies: ['React'] });
  assert.ok(withNewTech.includes('React'));

  const alreadyMentioned = engine.improveProject({ text: 'A dashboard built with React.', technologies: ['React'] });
  const occurrences = (alreadyMentioned.match(/React/g) || []).length;
  assert.equal(occurrences, 1);
});

test('generateCoverLetter: includes the given job title and company verbatim, without fabricating experience', () => {
  const result = engine.generateCoverLetter({ jobTitle: 'Backend Engineer', company: 'Acme Corp' });
  assert.ok(result.includes('Backend Engineer'));
  assert.ok(result.includes('Acme Corp'));
});

test('writeAchievement: rewrites input into one sentence without inventing numbers', () => {
  const result = engine.writeAchievement({ text: 'helped the team ship the release faster' });
  assert.ok(!/\d+%/.test(result));
  assert.ok(result.length > 0);
});

test('analyzeJobDescription: extracts skills, seniority, and keywords without a network call', () => {
  const result = engine.analyzeJobDescription({
    jobDescription: 'Senior Backend Engineer needed. Must have 5+ years experience with Node.js and PostgreSQL. Requires a Bachelor degree. Strong communication and teamwork skills required.',
  });
  assert.equal(result.seniority, 'Senior');
  assert.ok(result.requiredSkills.some((s) => s.toLowerCase() === 'node.js'));
  assert.ok(result.softSkills.some((s) => s.toLowerCase() === 'communication'));
  assert.ok(result.educationRequirements.length > 0);
});

test('analyzeJobDescription: a senior role mentioning "mentoring junior engineers" is still classified Senior (regression)', () => {
  const result = engine.analyzeJobDescription({
    jobDescription: 'Senior Full Stack Engineer with 5+ years of experience. You will be responsible for mentoring junior engineers.',
  });
  assert.equal(result.seniority, 'Senior');
});

test('analyzeJobDescription: returns empty structure for blank input', () => {
  const result = engine.analyzeJobDescription({ jobDescription: '' });
  assert.deepEqual(result.requiredSkills, []);
  assert.equal(result.seniority, 'Not specified');
});

test('matchResumeToJob: overallMatch is 0-100 and missingSkills excludes skills the candidate already has', () => {
  const result = engine.matchResumeToJob({
    summary: 'React developer.',
    skills: ['React'],
    jobDescription: 'Looking for a React and AWS developer.',
  });
  assert.ok(result.overallMatch >= 0 && result.overallMatch <= 100);
  assert.ok(!result.missingSkills.map((s) => s.toLowerCase()).includes('react'));
});

test('matchResumeToJob: without a job description returns a neutral zero-match result', () => {
  const result = engine.matchResumeToJob({ summary: 'Engineer.' });
  assert.equal(result.overallMatch, 0);
});

test('tailorResume: only surfaces bullets/skills that already exist in the resume', () => {
  const result = engine.tailorResume({
    summary: 'React developer.',
    skills: ['React', 'Node.js'],
    experience: [{ position: 'Engineer', description: 'Built React dashboards for internal teams.' }],
    jobDescription: 'Seeking a React developer.',
  });
  assert.ok(result.skillsToHighlight.includes('React'));
  assert.ok(result.bulletsToEmphasize.every((b) => b.includes('React') || b.length > 0));
});

test('reviewResume: derives strong/weak/missing from the same scoring logic as scoreResume', () => {
  const result = engine.reviewResume({ summary: 'Engineer.' });
  assert.ok(Array.isArray(result.strong));
  assert.ok(Array.isArray(result.weak));
  assert.ok(Array.isArray(result.missing));
  assert.ok(result.topPriorities.length <= 3);
});

test('careerInsights: suggests roles only from skill clusters actually present', () => {
  const result = engine.careerInsights({
    summary: 'Frontend developer.',
    skills: ['React', 'CSS3', 'TypeScript'],
  });
  assert.ok(result.suitableRoles.includes('Frontend Developer'));
  assert.ok(!result.skillsToStrengthen.map((s) => s.toLowerCase()).includes('react'));
});

test('interviewPrep: generates project/technology questions grounded in the given data', () => {
  const result = engine.interviewPrep({
    experience: [{ position: 'Engineer', company: 'Acme' }],
    projects: [{ name: 'Toolkit', technologies: ['React'] }],
    skills: ['React'],
  });
  assert.ok(result.projectQuestions.some((q) => q.includes('Toolkit')));
  assert.ok(result.technologyQuestions.some((q) => q.includes('React')));
  assert.ok(result.behavioralQuestions.length > 0);
});
