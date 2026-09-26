const mongoose = require('mongoose');

const checkInSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    feeling: {
      type: String,
      required: true,
      trim: true,
    },
    date: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

checkInSchema.methods.toClient = function toClient() {
  return {
    id: this._id.toString(),
    userId: this.userId.toString(),
    feeling: this.feeling,
    date: this.date,
  };
};

module.exports = mongoose.model('CheckIn', checkInSchema);
