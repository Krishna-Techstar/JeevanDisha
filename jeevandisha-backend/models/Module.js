const mongoose = require('mongoose');

const moduleSchema = new mongoose.Schema(
  {
    moduleNumber: {
      type: Number,
      required: true,
      unique: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      default: '',
    },
    icon: {
      type: String,
      default: '📘',
    },
    order: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

moduleSchema.methods.toClient = function toClient(extra = {}) {
  return {
    id: this._id.toString(),
    moduleNumber: this.moduleNumber,
    title: this.title,
    description: this.description,
    icon: this.icon,
    order: this.order,
    progress: extra.progress ?? 0,
    activities: extra.activities ?? [],
  };
};

module.exports = mongoose.model('Module', moduleSchema);
