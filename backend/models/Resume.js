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
      enum: ['modern', 'minimalAts', 'professional', 'creative', 'executive'],
      default: 'modern',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Resume', resumeSchema);
