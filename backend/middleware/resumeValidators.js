const { body, param } = require('express-validator');

// Structural shape check only — the controller's field whitelist is what
// actually protects against arbitrary/unexpected fields being persisted.
const sectionsValidator = (sections) => {
  if (sections === undefined) return true;
  if (!Array.isArray(sections)) {
    throw new Error('Sections must be an array');
  }
  for (const section of sections) {
    if (!section || typeof section !== 'object' || Array.isArray(section)) {
      throw new Error('Each section must be an object');
    }
    if (typeof section.key !== 'string' || !section.key.trim()) {
      throw new Error('Each section requires a key');
    }
    if (typeof section.title !== 'string') {
      throw new Error('Each section requires a title');
    }
    if (!Array.isArray(section.items)) {
      throw new Error('Section items must be an array');
    }
    for (const item of section.items) {
      if (!item || typeof item !== 'object' || Array.isArray(item)) {
        throw new Error('Each section item must be an object');
      }
    }
  }
  return true;
};

const resumeIdParamRules = [param('id').isMongoId().withMessage('Invalid resume id')];

const TEMPLATE_IDS = ['modern', 'minimalAts', 'professional', 'creative', 'executive'];

const createResumeRules = [
  body('title').trim().notEmpty().withMessage('Title is required').isLength({ max: 200 }),
  body('summary').optional().isString().isLength({ max: 5000 }),
  body('status').optional().isIn(['draft', 'published']).withMessage('Invalid status'),
  body('template').optional().isIn(TEMPLATE_IDS).withMessage('Invalid template'),
  body('sections').optional().custom(sectionsValidator),
  body('coverLetter').optional().isString().isLength({ max: 5000 }),
];

// Update payloads may legitimately include an empty title/summary mid-edit
// (autosave fires on every debounce tick), so those are type/length-checked
// but not required to be non-empty here.
const updateResumeRules = [
  body('title').optional().isString().isLength({ max: 200 }).withMessage('Title must be a string up to 200 characters'),
  body('summary').optional().isString().isLength({ max: 5000 }),
  body('status').optional().isIn(['draft', 'published']).withMessage('Invalid status'),
  body('template').optional().isIn(TEMPLATE_IDS).withMessage('Invalid template'),
  body('sections').optional().custom(sectionsValidator),
  body('coverLetter').optional().isString().isLength({ max: 5000 }),
];

module.exports = { resumeIdParamRules, createResumeRules, updateResumeRules };
