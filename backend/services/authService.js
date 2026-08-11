const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { signToken, verifyToken } = require('../utils/jwtUtils');

// Used to normalize response timing when no matching user exists, so a
// missing account can't be distinguished from a real one by how long the
// bcrypt comparison took (a real hash costs the same to compare against
// as any other real hash, unlike skipping the comparison entirely).
const DUMMY_HASH = bcrypt.hashSync('timing-normalization-only', 12);

const registerUser = async ({ fullName, email, phone, password }) => {
  if (!fullName || !email || !phone || !password) {
    throw { status: 400, message: 'All fields are required' };
  }

  const existingEmail = await User.findOne({ email: email.toLowerCase().trim() });
  if (existingEmail) {
    throw { status: 409, message: 'Email is already registered' };
  }

  const existingPhone = await User.findOne({ phone: phone.trim() });
  if (existingPhone) {
    throw { status: 409, message: 'Phone number is already registered' };
  }

  const hashedPassword = await bcrypt.hash(password, 12);
  const user = await User.create({
    fullName: fullName.trim(),
    email: email.toLowerCase().trim(),
    phone: phone.trim(),
    password: hashedPassword,
    role: 'user',
  });

  return user;
};

const loginUser = async ({ email, password }) => {
  if (!email || !password) {
    throw { status: 400, message: 'Email and password are required' };
  }

  const user = await User.findOne({ email: email.toLowerCase().trim() });
  if (!user) {
    throw { status: 401, message: 'Invalid email or password' };
  }

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) {
    throw { status: 401, message: 'Invalid email or password' };
  }

  const accessToken = signToken(
    { userId: user._id, role: user.role },
    process.env.JWT_SECRET,
    process.env.JWT_EXPIRES_IN || '1d'
  );

  const refreshToken = signToken(
    { userId: user._id, role: user.role },
    process.env.REFRESH_TOKEN_SECRET,
    process.env.REFRESH_TOKEN_EXPIRES_IN || '7d'
  );

  user.refreshTokenHash = await bcrypt.hash(refreshToken, 12);
  await user.save();

  return { user, accessToken, refreshToken };
};

const logoutUser = async ({ refreshToken }) => {
  if (!refreshToken) {
    throw { status: 400, message: 'Refresh token is required' };
  }

  let decoded;
  try {
    decoded = verifyToken(refreshToken, process.env.REFRESH_TOKEN_SECRET);
  } catch (error) {
    throw { status: 400, message: 'Invalid refresh token' };
  }

  const user = await User.findById(decoded.userId);
  if (!user || !user.refreshTokenHash) {
    throw { status: 400, message: 'Invalid refresh token' };
  }

  const isMatch = await bcrypt.compare(refreshToken, user.refreshTokenHash);
  if (!isMatch) {
    throw { status: 400, message: 'Invalid refresh token' };
  }

  user.refreshTokenHash = '';
  await user.save();

  return { message: 'Logged out successfully' };
};

const refreshAccessToken = async ({ refreshToken }) => {
  if (!refreshToken) {
    throw { status: 400, message: 'Refresh token is required' };
  }

  let decoded;
  try {
    decoded = verifyToken(refreshToken, process.env.REFRESH_TOKEN_SECRET);
  } catch (error) {
    throw { status: 401, message: 'Invalid refresh token' };
  }

  const user = await User.findById(decoded.userId);
  if (!user || !user.refreshTokenHash) {
    throw { status: 401, message: 'Invalid refresh token' };
  }

  const isMatch = await bcrypt.compare(refreshToken, user.refreshTokenHash);
  if (!isMatch) {
    throw { status: 401, message: 'Invalid refresh token' };
  }

  const accessToken = signToken(
    { userId: user._id, role: user.role },
    process.env.JWT_SECRET,
    process.env.JWT_EXPIRES_IN || '1d'
  );

  return { accessToken };
};

// Returns the same generic message and 200 status whether or not the email
// is registered, so this endpoint can't be used to enumerate accounts.
const forgotPassword = async ({ email }) => {
  if (!email) {
    throw { status: 400, message: 'Email is required' };
  }

  const genericMessage = 'If this email is registered, a password reset code has been generated.';
  const user = await User.findOne({ email: email.toLowerCase().trim() });

  if (!user) {
    await bcrypt.compare('unused', DUMMY_HASH); // timing normalization, see DUMMY_HASH
    return { message: genericMessage };
  }

  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  user.passwordResetOtpHash = await bcrypt.hash(otp, 12);
  user.passwordResetExpires = Date.now() + 1000 * 60 * 15;
  await user.save();

  // No email provider is configured yet. In development the OTP is logged
  // server-side only, never returned in the API response. Production needs a
  // real delivery mechanism (e.g. nodemailer + a transactional email provider)
  // before this flow can be used with real users.
  if (process.env.NODE_ENV !== 'production') {
    console.log(`[DEV ONLY] Password reset OTP for ${user.email}: ${otp}`);
  }

  return { message: genericMessage };
};

// Same non-enumeration principle as forgotPassword: an unknown email and a
// wrong/expired OTP for a real email both fail with the identical message,
// so this endpoint can't be used to confirm whether an email is registered.
const resetPassword = async ({ email, otp, password }) => {
  if (!email || !otp || !password) {
    throw { status: 400, message: 'Email, OTP and password are required' };
  }

  const genericError = { status: 400, message: 'Invalid or expired OTP' };
  const user = await User.findOne({ email: email.toLowerCase().trim() });

  if (!user) {
    await bcrypt.compare(otp, DUMMY_HASH); // timing normalization, see DUMMY_HASH
    throw genericError;
  }

  const isExpired = !user.passwordResetExpires || user.passwordResetExpires < Date.now();
  const isMatch = user.passwordResetOtpHash && (await bcrypt.compare(otp, user.passwordResetOtpHash));

  if (isExpired || !isMatch) {
    throw genericError;
  }

  user.password = await bcrypt.hash(password, 12);
  user.passwordResetOtpHash = '';
  user.passwordResetExpires = null;
  await user.save();

  return { message: 'Password reset successfully' };
};

module.exports = {
  registerUser,
  loginUser,
  logoutUser,
  refreshAccessToken,
  forgotPassword,
  resetPassword,
};
