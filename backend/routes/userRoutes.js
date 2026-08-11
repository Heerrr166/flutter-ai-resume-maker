const express = require('express');
const userController = require('../controllers/userController');
const { authenticate, authorize } = require('../middleware/authMiddleware');
const { validate } = require('../middleware/validate');
const { userIdParamRules, listUsersRules } = require('../middleware/userValidators');

const router = express.Router();

router.get('/profile', authenticate, userController.getProfile);
router.put('/profile', authenticate, userController.updateProfile);

// Was previously mounted at '/users' under a router already mounted at
// '/api/users', making the real path '/api/users/users' with no frontend
// consumer. Fixed to the conventional '/api/users' (list) now that the
// admin screen actually calls it.
router.get('/', authenticate, authorize('admin'), listUsersRules, validate, userController.getAllUsers);
router.delete('/:id', authenticate, authorize('admin'), userIdParamRules, validate, userController.deleteUser);

module.exports = router;
