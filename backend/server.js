const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const resumeRoutes = require('./routes/resumeRoutes');
const aiRoutes = require('./routes/aiRoutes');
const errorHandler = require('./middleware/errorHandler');
const User = require('./models/User');
const bcrypt = require('bcryptjs');

dotenv.config();
const app = express();

// CLIENT_URL may be a single origin or a comma-separated list of allowed
// browser origins. Native/mobile clients (Dio on Android/iOS) send no Origin
// header at all, so they are unaffected by this and always pass through.
const allowedOrigins = (process.env.CLIENT_URL || '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);
const allowAnyDevelopmentOrigin = process.env.NODE_ENV !== 'production';

const corsOptions = {
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);
    if (allowAnyDevelopmentOrigin || allowedOrigins.includes(origin)) return callback(null, true);
    const corsError = new Error('Not allowed by CORS');
    corsError.status = 403;
    return callback(corsError);
  },
};

// This is a pure JSON API consumed cross-origin by the Flutter Web client
// (a different port counts as a different origin), so the resource policy
// must allow cross-origin reads or browsers will block responses even when
// CORS headers are otherwise correct.
app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(cors(corsOptions));
app.use(express.json({ limit: '1mb' }));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/resumes', resumeRoutes);
app.use('/api/ai', aiRoutes);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;

// Admin seeding is opt-in via env vars so no credentials ever live in source.
// Set ADMIN_EMAIL and ADMIN_PASSWORD (and optionally ADMIN_FULL_NAME /
// ADMIN_PHONE) to have an admin account created automatically on startup.
const seedAdminAccount = async () => {
  const adminEmail = process.env.ADMIN_EMAIL;
  const adminPassword = process.env.ADMIN_PASSWORD;

  if (!adminEmail || !adminPassword) {
    if (process.env.NODE_ENV !== 'production') {
      console.warn('Admin seed skipped: set ADMIN_EMAIL and ADMIN_PASSWORD in .env to auto-create an admin account.');
    }
    return;
  }

  const normalizedEmail = adminEmail.toLowerCase().trim();
  const existingAdmin = await User.findOne({ email: normalizedEmail });
  if (existingAdmin) return;

  const hashedPassword = await bcrypt.hash(adminPassword, 12);
  await User.create({
    fullName: process.env.ADMIN_FULL_NAME || 'Admin User',
    email: normalizedEmail,
    phone: process.env.ADMIN_PHONE || '+10000000000',
    password: hashedPassword,
    role: 'admin',
    profileImage: '',
    isVerified: true,
  });
  console.log(`Admin account ensured for ${normalizedEmail} (credentials read from environment, not logged).`);
};

connectDB()
  .then(async () => {
    await seedAdminAccount();

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on 0.0.0.0:${PORT}`);
    });
  })
  .catch((error) => {
    console.error('Database connection failed', error);
    process.exit(1);
  });
