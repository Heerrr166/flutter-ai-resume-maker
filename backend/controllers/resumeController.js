const Resume = require('../models/Resume');

const ALLOWED_RESUME_FIELDS = ['title', 'summary', 'sections', 'status', 'template', 'coverLetter'];

const sanitizeResume = (resume) => {
  if (!resume) return null;
  return resume.toObject({ getters: true, virtuals: false });
};

// Whitelist writable fields so clients can never set `user`, `_id`, or other
// unexpected fields through create/update payloads.
const pickResumeFields = (payload = {}) => {
  const result = {};
  for (const field of ALLOWED_RESUME_FIELDS) {
    if (payload[field] !== undefined) {
      result[field] = payload[field];
    }
  }
  return result;
};

exports.createResume = async (req, res, next) => {
  try {
    const payload = pickResumeFields(req.body);
    payload.user = req.user._id;

    if (!payload.title || typeof payload.title !== 'string') {
      return res.status(400).json({ success: false, message: 'Title is required' });
    }

    const resume = await Resume.create(payload);
    return res.status(201).json({ success: true, data: sanitizeResume(resume) });
  } catch (error) {
    next(error);
  }
};

exports.getResumes = async (req, res, next) => {
  try {
    const resumes = await Resume.find({ user: req.user._id }).sort({ updatedAt: -1 });
    return res.json({ success: true, data: resumes.map(sanitizeResume) });
  } catch (error) {
    next(error);
  }
};

exports.getResume = async (req, res, next) => {
  try {
    const { id } = req.params;
    const resume = await Resume.findOne({ _id: id, user: req.user._id });
    if (!resume) return res.status(404).json({ success: false, message: 'Resume not found' });
    return res.json({ success: true, data: sanitizeResume(resume) });
  } catch (error) {
    next(error);
  }
};

exports.updateResume = async (req, res, next) => {
  try {
    const { id } = req.params;
    const payload = pickResumeFields(req.body);
    const resume = await Resume.findOneAndUpdate({ _id: id, user: req.user._id }, { $set: payload }, { new: true, runValidators: true });
    if (!resume) return res.status(404).json({ success: false, message: 'Resume not found' });
    return res.json({ success: true, data: sanitizeResume(resume) });
  } catch (error) {
    next(error);
  }
};

exports.deleteResume = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await Resume.findOneAndDelete({ _id: id, user: req.user._id });
    if (!result) return res.status(404).json({ success: false, message: 'Resume not found' });
    return res.json({ success: true, message: 'Resume deleted' });
  } catch (error) {
    next(error);
  }
};
