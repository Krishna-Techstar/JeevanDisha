const mongoose = require('mongoose');

const goalSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    goal: {
      type: String,
      required: true,
      trim: true,
    },
    action: {
      type: String,
      default: '',
      trim: true,
    },
    schedule: {
      type: String,
      default: '',
      trim: true,
    },
    targetDate: {
      type: Date,
      default: null,
    },
    firstStep: {
      type: String,
      default: '',
      trim: true,
    },
    status: {
      type: String,
      enum: ['active', 'completed'],
      default: 'active',
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: { createdAt: true, updatedAt: true } }
);

goalSchema.methods.toClient = function toClient() {
  return {
    id: this._id.toString(),
    goal: this.goal,
    action: this.action,
    schedule: this.schedule,
    targetDate: this.targetDate,
    firstStep: this.firstStep,
    status: this.status,
    createdAt: this.createdAt,
  };
};

module.exports = mongoose.model('Goal', goalSchema);
