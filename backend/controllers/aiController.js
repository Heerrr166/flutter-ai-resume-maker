const aiService = require('../services/aiService');

const generateSummary = async (req, res, next) => {
  try {
    const message = await aiService.generateSummary(req.body);
    res.status(200).json({ success: true, data: { summary: message } });
  } catch (error) {
    next(error);
  }
};

const improveExperience = async (req, res, next) => {
  try {
    const message = await aiService.improveExperience(req.body);
    res.status(200).json({ success: true, data: { text: message } });
  } catch (error) {
    next(error);
  }
};

const improveProject = async (req, res, next) => {
  try {
    const message = await aiService.improveProject(req.body);
    res.status(200).json({ success: true, data: { text: message } });
  } catch (error) {
    next(error);
  }
};

const writeAchievement = async (req, res, next) => {
  try {
    const message = await aiService.writeAchievement(req.body);
    res.status(200).json({ success: true, data: { text: message } });
  } catch (error) {
    next(error);
  }
};

const recommendSkills = async (req, res, next) => {
  try {
    const skills = await aiService.recommendSkills(req.body);
    res.status(200).json({ success: true, data: { skills } });
  } catch (error) {
    next(error);
  }
};

const scoreResume = async (req, res, next) => {
  try {
    const result = await aiService.scoreResume(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

const generateCoverLetter = async (req, res, next) => {
  try {
    const coverLetter = await aiService.generateCoverLetter(req.body);
    res.status(200).json({ success: true, data: { coverLetter } });
  } catch (error) {
    next(error);
  }
};

const analyzeJobDescription = async (req, res, next) => {
  try {
    const result = await aiService.analyzeJobDescription(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

const matchResumeToJob = async (req, res, next) => {
  try {
    const result = await aiService.matchResumeToJob(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

const tailorResume = async (req, res, next) => {
  try {
    const result = await aiService.tailorResume(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

const reviewResume = async (req, res, next) => {
  try {
    const result = await aiService.reviewResume(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

const careerInsights = async (req, res, next) => {
  try {
    const result = await aiService.careerInsights(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

const interviewPrep = async (req, res, next) => {
  try {
    const result = await aiService.interviewPrep(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
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
