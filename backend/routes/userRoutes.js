const express = require('express');
const userController = require('../controllers/userController');
const { authenticate, authorize } = require('../middleware/authMiddleware');
const { validate } = require('../middleware/validate');
const { userIdParamRules, listUsersRules } = require('../middleware/userValidators');

const router = express.Router();

router.get('/profile', authenticate, userController.getProfile);
router.put('/profile', authenticate, userController.updateProfile);

// Admin-specific platform statistics
router.get('/admin/stats', authenticate, authorize('admin'), userController.getAdminOverviewStats);

router.get('/', authenticate, authorize('admin'), listUsersRules, validate, userController.getAllUsers);
router.delete('/:id', authenticate, authorize('admin'), userIdParamRules, validate, userController.deleteUser);

module.exports = router;
