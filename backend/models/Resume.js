const mongoose = require('mongoose');

const SectionSchema = new mongoose.Schema(
  {
    key: { type: String, required: true },
    title: { type: String, required: true },
    items: { type: Array, default: [] },
    order: { type: Number, default: 0 },
  },
  { _id: false }
);

const TEMPLATE_IDS = [
  'modern',
  'minimalAts',
  'professional',
  'creative',
  'executive',
  'techDeveloper',
  'dataAnalytics',
  'corporate',
  'studentFresher',
  'academic',
  'marketing',
  'finance',
  'elegantMonochrome',
  'boldHeader',
  'cleanTwoColumn',
  'compactAts',
];

const resumeSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true, trim: true },
    summary: { type: String, default: '' },
    sections: { type: [SectionSchema], default: [] },
    coverLetter: { type: String, default: '' },
    meta: { type: Object, default: {} },
    status: { type: String, enum: ['draft', 'published'], default: 'draft' },
    template: {
      type: String,
      enum: TEMPLATE_IDS,
      default: 'modern',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Resume', resumeSchema);
