const express = require('express');
const router = express.Router();
const resumeController = require('../controllers/resumeController');
const { authenticate, authorize } = require('../middleware/authMiddleware');
const { resumeLimiter } = require('../middleware/rateLimiter');
const { validate } = require('../middleware/validate');
const {
  resumeIdParamRules,
  createResumeRules,
  updateResumeRules,
} = require('../middleware/resumeValidators');

router.use(resumeLimiter);

// Platform-wide resumes for Admin Console
router.get('/admin/all', authenticate, authorize('admin'), resumeController.getAllResumesAdmin);

router.post('/', authenticate, createResumeRules, validate, resumeController.createResume);
router.get('/', authenticate, resumeController.getResumes);
router.get('/:id', authenticate, resumeIdParamRules, validate, resumeController.getResume);
router.put('/:id', authenticate, resumeIdParamRules, updateResumeRules, validate, resumeController.updateResume);
router.delete('/:id', authenticate, resumeIdParamRules, validate, resumeController.deleteResume);

module.exports = router;
