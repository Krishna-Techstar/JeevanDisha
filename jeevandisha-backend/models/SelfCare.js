const mongoose = require('mongoose');

const selfCareSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    water: {
      type: Boolean,
      default: false,
    },
    meals: {
      type: Boolean,
      default: false,
    },
    physicalActivity: {
      type: Boolean,
      default: false,
    },
    relaxation: {
      type: Boolean,
      default: false,
    },
    socialConnection: {
      type: Boolean,
      default: false,
    },
    sleep: {
      type: Boolean,
      default: false,
    },
    date: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

selfCareSchema.methods.toClient = function toClient() {
  return {
    id: this._id.toString(),
    userId: this.userId.toString(),
    water: this.water,
    meals: this.meals,
    physicalActivity: this.physicalActivity,
    relaxation: this.relaxation,
    socialConnection: this.socialConnection,
    sleep: this.sleep,
    date: this.date,
  };
};

module.exports = mongoose.model('SelfCare', selfCareSchema);
