const mongoose = require('mongoose');

const ACTIVITY_TYPES = ['learn', 'understand', 'practice', 'reflect', 'apply'];

const activitySchema = new mongoose.Schema(
  {
    moduleId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Module',
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      enum: ACTIVITY_TYPES,
      required: true,
    },
    order: {
      type: Number,
      required: true,
      default: 0,
    },
    learnContent: {
      heading: { type: String, default: '' },
      body: { type: String, default: '' },
      keyIdea: { type: String, default: '' },
    },
    understandContent: {
      scenario: { type: String, default: '' },
      options: [
        {
          text: { type: String, required: true },
          isCorrect: { type: Boolean, default: false },
        },
      ],
      explanation: { type: String, default: '' },
    },
    practiceFields: [
      {
        label: { type: String, required: true },
        placeholder: { type: String, default: '' },
      },
    ],
    reflectionQuestions: [
      {
        type: String,
      },
    ],
    applyPrompt: {
      type: String,
      default: '',
    },
    estimatedMinutes: {
      type: Number,
      default: 5,
    },
  },
  { timestamps: true }
);

activitySchema.methods.toClient = function toClient(response = null) {
  return {
    id: this._id.toString(),
    moduleId: this.moduleId.toString(),
    title: this.title,
    type: this.type,
    order: this.order,
    learnContent: this.learnContent || null,
    understandContent: this.understandContent || null,
    practiceFields: this.practiceFields || [],
    reflectionQuestions: this.reflectionQuestions || [],
    applyPrompt: this.applyPrompt || '',
    estimatedMinutes: this.estimatedMinutes,
    status: response?.status || null,
    completed: response?.status === 'completed',
  };
};

module.exports = mongoose.model('Activity', activitySchema);
module.exports.ACTIVITY_TYPES = ACTIVITY_TYPES;
