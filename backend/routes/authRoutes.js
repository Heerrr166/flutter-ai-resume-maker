const express = require('express');
const authController = require('../controllers/authController');
const { registerLimiter, loginLimiter, otpLimiter } = require('../middleware/rateLimiter');
const { validate } = require('../middleware/validate');
const {
  registerRules,
  loginRules,
  forgotPasswordRules,
  resetPasswordRules,
} = require('../middleware/authValidators');

const router = express.Router();

router.post('/register', registerLimiter, registerRules, validate, authController.register);
router.post('/login', loginLimiter, loginRules, validate, authController.login);
router.post('/refresh-token', authController.refreshToken);
router.post('/logout', authController.logout);
router.post('/forgot-password', otpLimiter, forgotPasswordRules, validate, authController.forgotPassword);
router.post('/reset-password', otpLimiter, resetPasswordRules, validate, authController.resetPassword);

module.exports = router;
