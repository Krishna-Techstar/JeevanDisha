const mongoose = require('mongoose');

const activityResponseSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    activityId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Activity',
      required: true,
      index: true,
    },
    practiceResponses: {
      type: Map,
      of: String,
      default: {},
    },
    reflectionResponses: {
      type: Map,
      of: String,
      default: {},
    },
    applyResponse: {
      type: String,
      default: '',
    },
    status: {
      type: String,
      enum: ['in_progress', 'completed'],
      default: 'in_progress',
    },
    startedAt: {
      type: Date,
      default: Date.now,
    },
    completedAt: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true }
);

activityResponseSchema.index({ userId: 1, activityId: 1 }, { unique: true });

activityResponseSchema.methods.toClient = function toClient() {
  return {
    id: this._id.toString(),
    userId: this.userId.toString(),
    activityId: this.activityId.toString(),
    practiceResponses: Object.fromEntries(this.practiceResponses || []),
    reflectionResponses: Object.fromEntries(this.reflectionResponses || []),
    applyResponse: this.applyResponse,
    status: this.status,
    startedAt: this.startedAt,
    completedAt: this.completedAt,
  };
};

module.exports = mongoose.model('ActivityResponse', activityResponseSchema);
