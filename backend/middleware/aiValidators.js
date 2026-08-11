const { body } = require('express-validator');

const MAX_TEXT = 5000;
const MAX_ARRAY = 20;
const MAX_ITEM = 500;

const optionalString = (field, max = MAX_ITEM) => body(field).optional().isString().isLength({ max });
const optionalStringArray = (field) =>
  body(field)
    .optional()
    .isArray({ max: MAX_ARRAY })
    .withMessage(`${field} must be an array with at most ${MAX_ARRAY} items`)
    .custom((arr) => arr.every((v) => typeof v === 'string' && v.length <= MAX_ITEM))
    .withMessage(`${field} items must be strings up to ${MAX_ITEM} characters`);
const optionalObjectArray = (field) =>
  body(field)
    .optional()
    .isArray({ max: MAX_ARRAY })
    .withMessage(`${field} must be an array with at most ${MAX_ARRAY} items`)
    .custom((arr) => arr.every((v) => v && typeof v === 'object' && !Array.isArray(v)))
    .withMessage(`${field} items must be objects`);

const hasAnyContent = (fields) => (_, { req }) => {
  const hasContent = fields.some((f) => {
    const v = req.body[f];
    if (v == null) return false;
    if (typeof v === 'string') return v.trim().length > 0;
    if (Array.isArray(v)) return v.length > 0;
    return false;
  });
  if (!hasContent) throw new Error(`At least one of ${fields.join(', ')} is required`);
  return true;
};

const summaryRules = [
  optionalString('currentSummary', MAX_TEXT),
  optionalObjectArray('experience'),
  optionalStringArray('skills'),
  optionalObjectArray('education'),
  body().custom(hasAnyContent(['currentSummary', 'experience', 'skills', 'education'])),
];

const experienceImproveRules = [
  body('text').trim().notEmpty().withMessage('text is required').isLength({ max: MAX_TEXT }),
  optionalString('position'),
  optionalString('company'),
];

const projectImproveRules = [
  body('text').trim().notEmpty().withMessage('text is required').isLength({ max: MAX_TEXT }),
  optionalString('name'),
  optionalStringArray('technologies'),
];

const skillsRecommendRules = [
  optionalString('summary', MAX_TEXT),
  optionalStringArray('experience'),
  optionalStringArray('existingSkills'),
  body().custom(hasAnyContent(['summary', 'experience'])),
];

const scoreResumeRules = [
  optionalString('summary', MAX_TEXT),
  optionalObjectArray('experience'),
  optionalObjectArray('education'),
  optionalStringArray('skills'),
  optionalObjectArray('projects'),
  optionalString('jobDescription', MAX_TEXT),
];

const coverLetterRules = [
  body('jobTitle').trim().notEmpty().withMessage('jobTitle is required').isLength({ max: 200 }),
  body('company').trim().notEmpty().withMessage('company is required').isLength({ max: 200 }),
  optionalString('summary', MAX_TEXT),
  optionalStringArray('experience'),
  optionalString('jobDescription', MAX_TEXT),
];

const achievementImproveRules = [
  body('text').trim().notEmpty().withMessage('text is required').isLength({ max: MAX_TEXT }),
];

const jdAnalyzeRules = [
  body('jobDescription').trim().notEmpty().withMessage('jobDescription is required').isLength({ max: MAX_TEXT }),
];

const resumeJobMatchRules = [
  body('jobDescription').trim().notEmpty().withMessage('jobDescription is required').isLength({ max: MAX_TEXT }),
  optionalString('summary', MAX_TEXT),
  optionalObjectArray('experience'),
  optionalObjectArray('education'),
  optionalStringArray('skills'),
  optionalObjectArray('projects'),
];

const tailorResumeRules = [
  body('jobDescription').trim().notEmpty().withMessage('jobDescription is required').isLength({ max: MAX_TEXT }),
  optionalString('summary', MAX_TEXT),
  optionalObjectArray('experience'),
  optionalStringArray('skills'),
  optionalObjectArray('projects'),
];

const reviewResumeRules = [
  optionalString('summary', MAX_TEXT),
  optionalObjectArray('experience'),
  optionalObjectArray('education'),
  optionalStringArray('skills'),
  optionalObjectArray('projects'),
  body().custom(hasAnyContent(['summary', 'experience', 'education', 'skills', 'projects'])),
];

const careerInsightsRules = [
  optionalString('summary', MAX_TEXT),
  optionalObjectArray('experience'),
  optionalStringArray('skills'),
  optionalObjectArray('projects'),
  optionalString('targetRole', 200),
  body().custom(hasAnyContent(['summary', 'experience', 'skills', 'projects'])),
];

const interviewPrepRules = [
  optionalObjectArray('experience'),
  optionalObjectArray('projects'),
  optionalStringArray('skills'),
  optionalString('jobDescription', MAX_TEXT),
  body().custom(hasAnyContent(['experience', 'projects', 'skills'])),
];

module.exports = {
  summaryRules,
  experienceImproveRules,
  projectImproveRules,
  skillsRecommendRules,
  scoreResumeRules,
  coverLetterRules,
  achievementImproveRules,
  jdAnalyzeRules,
  resumeJobMatchRules,
  tailorResumeRules,
  reviewResumeRules,
  careerInsightsRules,
  interviewPrepRules,
};
