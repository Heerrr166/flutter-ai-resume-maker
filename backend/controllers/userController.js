const User = require('../models/User');
const Resume = require('../models/Resume');

// Excludes both the current hashed-secret fields and legacy plaintext field
// names (refreshToken, passwordResetOtp) that predate the hashing migration
// and can still be present on documents written before it — a bare
// '-refreshTokenHash -passwordResetOtpHash' exclusion does not touch those.
const SAFE_USER_EXCLUSIONS =
  '-password -refreshTokenHash -passwordResetOtpHash -passwordResetExpires -refreshToken -passwordResetOtp';

const getProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).select(SAFE_USER_EXCLUSIONS);
    res.status(200).json({ success: true, data: { user } });
  } catch (error) {
    next(error);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    const updates = req.body;
    const allowedUpdates = ['fullName', 'phone'];
    const filtered = {};

    Object.keys(updates).forEach((key) => {
      if (allowedUpdates.includes(key)) {
        filtered[key] = updates[key];
      }
    });

    const user = await User.findByIdAndUpdate(req.user._id, filtered, { new: true, runValidators: true }).select(SAFE_USER_EXCLUSIONS);
    res.status(200).json({ success: true, data: { user } });
  } catch (error) {
    next(error);
  }
};

const getAllUsers = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 20, 1), 100);
    const skip = (page - 1) * limit;
    const search = req.query.search ? req.query.search.trim() : '';
    const role = req.query.role ? req.query.role.trim() : '';

    const filter = {};
    if (role && role !== 'any' && role !== 'all') {
      filter.role = role;
    }
    if (search) {
      filter.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
      ];
    }

    const [users, total] = await Promise.all([
      User.find(filter)
        .select(SAFE_USER_EXCLUSIONS)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      User.countDocuments(filter),
    ]);

    res.status(200).json({
      success: true,
      data: { users, total, page, totalPages: Math.max(Math.ceil(total / limit), 1) },
    });
  } catch (error) {
    next(error);
  }
};

const getAdminOverviewStats = async (req, res, next) => {
  try {
    const [totalUsers, totalAdmins, verifiedUsers, totalResumes, publishedResumes, draftResumes, recentUsers, recentResumes] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ role: 'admin' }),
      User.countDocuments({ isVerified: true }),
      Resume.countDocuments(),
      Resume.countDocuments({ status: 'published' }),
      Resume.countDocuments({ status: { $ne: 'published' } }),
      User.find().select(SAFE_USER_EXCLUSIONS).sort({ createdAt: -1 }).limit(5),
      Resume.find().populate('user', 'fullName email').sort({ updatedAt: -1 }).limit(5),
    ]);

    res.status(200).json({
      success: true,
      data: {
        stats: {
          totalUsers,
          totalAdmins,
          verifiedUsers,
          regularUsers: Math.max(totalUsers - totalAdmins, 0),
          totalResumes,
          publishedResumes,
          draftResumes,
        },
        recentUsers,
        recentResumes: recentResumes.map(r => ({
          ...r.toObject({ getters: true }),
          ownerName: r.user ? r.user.fullName : 'Unknown User',
          ownerEmail: r.user ? r.user.email : '',
        })),
      },
    });
  } catch (error) {
    next(error);
  }
};

// Deletes a user and cascades to their resumes so no resume is left pointing
// at a user that no longer exists. Self-deletion is blocked so an admin can
// never lock themselves out.
const deleteUser = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (id === req.user._id.toString()) {
      return res.status(400).json({ success: false, message: 'You cannot delete your own account' });
    }

    const user = await User.findByIdAndDelete(id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    await Resume.deleteMany({ user: id });

    res.status(200).json({ success: true, message: 'User deleted' });
  } catch (error) {
    next(error);
  }
};

module.exports = { getProfile, updateProfile, getAllUsers, getAdminOverviewStats, deleteUser };
