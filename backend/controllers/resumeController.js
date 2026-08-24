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

exports.getAllResumesAdmin = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 20, 1), 100);
    const skip = (page - 1) * limit;
    const search = req.query.search ? req.query.search.trim() : '';
    const status = req.query.status ? req.query.status.trim() : '';

    const filter = {};
    if (status && status !== 'all' && status !== 'any') {
      filter.status = status;
    }
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { template: { $regex: search, $options: 'i' } },
      ];
    }

    const [resumes, total, publishedCount, draftCount] = await Promise.all([
      Resume.find(filter)
        .populate('user', 'fullName email')
        .sort({ updatedAt: -1 })
        .skip(skip)
        .limit(limit),
      Resume.countDocuments(filter),
      Resume.countDocuments({ status: 'published' }),
      Resume.countDocuments({ status: { $ne: 'published' } }),
    ]);

    return res.json({
      success: true,
      data: {
        resumes: resumes.map((r) => ({
          ...r.toObject({ getters: true }),
          ownerName: r.user ? r.user.fullName : 'Unknown User',
          ownerEmail: r.user ? r.user.email : '',
        })),
        total,
        page,
        totalPages: Math.max(Math.ceil(total / limit), 1),
        stats: {
          total,
          publishedCount,
          draftCount,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getResume = async (req, res, next) => {
  try {
    const { id } = req.params;
    // Admins can inspect any resume, while standard users can only view their own
    const query = req.user.role === 'admin' ? { _id: id } : { _id: id, user: req.user._id };
    const resume = await Resume.findOne(query);
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
    const query = req.user.role === 'admin' ? { _id: id } : { _id: id, user: req.user._id };
    const resume = await Resume.findOneAndUpdate(query, { $set: payload }, { new: true, runValidators: true });
    if (!resume) return res.status(404).json({ success: false, message: 'Resume not found' });
    return res.json({ success: true, data: sanitizeResume(resume) });
  } catch (error) {
    next(error);
  }
};

exports.deleteResume = async (req, res, next) => {
  try {
    const { id } = req.params;
    const query = req.user.role === 'admin' ? { _id: id } : { _id: id, user: req.user._id };
    const result = await Resume.findOneAndDelete(query);
    if (!result) return res.status(404).json({ success: false, message: 'Resume not found' });
    return res.json({ success: true, message: 'Resume deleted' });
  } catch (error) {
    next(error);
  }
};
