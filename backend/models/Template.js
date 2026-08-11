const mongoose = require('mongoose');

const templateSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, default: '' },
    fields: { type: Object, default: {} },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Template', templateSchema);
