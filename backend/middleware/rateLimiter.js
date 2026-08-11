const rateLimit = require('express-rate-limit');

// Register and login each get their own independently-tracked budget rather
// than sharing one counter. They previously shared a single authLimiter
// keyed by IP - since both routes drew from the same 20-request bucket, a
// burst of registration activity (e.g. signing up, then a duplicate-email
// check) could exhaust the budget and cause an unrelated, immediately-after
// login attempt to be rejected with a rate-limit error even though the
// credentials were entirely correct. Same strictness per action as before
// (20/15min), just no longer cross-contaminating two unrelated actions.
const registerLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many attempts. Please try again later.' },
});

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many attempts. Please try again later.' },
});

// Forgot-password/reset-password: stricter, since reset-password is also
// where a guessed OTP would be redeemed.
const otpLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many attempts. Please try again later.' },
});

// AI endpoints call a paid, rate-limited external provider — bounded tighter
// than general API traffic so one user can't run up cost/quota for everyone.
const aiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many AI requests. Please try again later.' },
});

// Resume CRUD: much more generous than auth/AI since autosave alone can fire
// a PUT roughly every 10s during active editing (~90 requests/15min from
// legitimate use) — this bounds abuse without interfering with normal use.
const resumeLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests. Please try again later.' },
});

module.exports = { registerLimiter, loginLimiter, otpLimiter, aiLimiter, resumeLimiter };
