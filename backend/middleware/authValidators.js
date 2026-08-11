const { body } = require('express-validator');

const registerRules = [
  body('fullName').trim().notEmpty().withMessage('Full name is required').isLength({ min: 2, max: 100 }),
  body('email').trim().notEmpty().isEmail().withMessage('A valid email is required'),
  body('phone')
    .trim()
    .notEmpty()
    .withMessage('Phone is required')
    .matches(/^\+?[0-9\s\-()]{7,20}$/)
    .withMessage('Invalid phone number'),
  body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
];

const loginRules = [
  body('email').trim().notEmpty().isEmail().withMessage('A valid email is required'),
  body('password').notEmpty().withMessage('Password is required'),
];

const forgotPasswordRules = [
  body('email').trim().notEmpty().isEmail().withMessage('A valid email is required'),
];

const resetPasswordRules = [
  body('email').trim().notEmpty().isEmail().withMessage('A valid email is required'),
  body('otp').trim().notEmpty().isLength({ min: 6, max: 6 }).isNumeric().withMessage('OTP must be a 6-digit code'),
  body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
];

module.exports = { registerRules, loginRules, forgotPasswordRules, resetPasswordRules };
