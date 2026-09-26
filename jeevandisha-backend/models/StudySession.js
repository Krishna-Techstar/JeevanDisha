const mongoose = require('mongoose');

const studySessionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    topic: {
      type: String,
      required: true,
      trim: true,
    },
    duration: {
      type: Number,
      default: 25,
    },
    recallPoints: {
      type: [String],
      validate: [
        (val) => !val || val.length <= 3,
        '{PATH} exceeds the limit of 3 items',
      ],
      default: [],
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

studySessionSchema.methods.toClient = function toClient() {
  return {
    id: this._id.toString(),
    userId: this.userId.toString(),
    topic: this.topic,
    duration: this.duration,
    recallPoints: this.recallPoints || [],
    status: this.status,
    startedAt: this.startedAt,
    completedAt: this.completedAt,
  };
};

module.exports = mongoose.model('StudySession', studySessionSchema);
