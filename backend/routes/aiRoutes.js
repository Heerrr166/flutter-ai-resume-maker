const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');
const { authenticate } = require('../middleware/authMiddleware');
const { aiLimiter } = require('../middleware/rateLimiter');
const { validate } = require('../middleware/validate');
const {
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
} = require('../middleware/aiValidators');

router.use(authenticate, aiLimiter);

router.post('/summary', summaryRules, validate, aiController.generateSummary);
router.post('/experience/improve', experienceImproveRules, validate, aiController.improveExperience);
router.post('/project/improve', projectImproveRules, validate, aiController.improveProject);
router.post('/achievement/improve', achievementImproveRules, validate, aiController.writeAchievement);
router.post('/skills/recommend', skillsRecommendRules, validate, aiController.recommendSkills);
router.post('/resume/score', scoreResumeRules, validate, aiController.scoreResume);
router.post('/cover-letter', coverLetterRules, validate, aiController.generateCoverLetter);
router.post('/job/analyze', jdAnalyzeRules, validate, aiController.analyzeJobDescription);
router.post('/resume/match', resumeJobMatchRules, validate, aiController.matchResumeToJob);
router.post('/resume/tailor', tailorResumeRules, validate, aiController.tailorResume);
router.post('/resume/review', reviewResumeRules, validate, aiController.reviewResume);
router.post('/career/insights', careerInsightsRules, validate, aiController.careerInsights);
router.post('/interview/prep', interviewPrepRules, validate, aiController.interviewPrep);

module.exports = router;
