const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    passwordHash: {
      type: String,
      required: true,
    },
    currentWeek: {
      type: Number,
      default: 1,
      min: 1,
      max: 6,
    },
    currentModule: {
      type: Number,
      default: 1,
      min: 1,
      max: 5,
    },
    phone: {
      type: String,
      default: '',
      trim: true,
    },
    prn: {
      type: String,
      default: '',
      trim: true,
      uppercase: true,
    },
    className: {
      type: String,
      default: '',
      trim: true,
    },
    division: {
      type: String,
      default: '',
      trim: true,
    },
    department: {
      type: String,
      default: '',
      trim: true,
    },
    specialization: {
      type: String,
      default: '',
      trim: true,
    },
    institutionName: {
      type: String,
      default: '',
      trim: true,
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
    updatedAt: {
      type: Date,
      default: Date.now,
    },
  }
);

// Pre-save hook that sets updatedAt to new Date() on every save
userSchema.pre('save', function (next) {
  this.updatedAt = new Date();
  if (typeof next === 'function') {
    next();
  }
});

// Helper static method for hashing passwords with bcryptjs saltRounds 10
userSchema.statics.hashPassword = async function hashPassword(plain) {
  return bcrypt.hash(plain, 10);
};

// Helper instance method for verifying passwords
userSchema.methods.matchPassword = function matchPassword(plain) {
  return bcrypt.compare(plain, this.passwordHash);
};

// Helper to return safe JSON without sensitive fields
userSchema.methods.toSafeJSON = function toSafeJSON() {
  return {
    id: this._id.toString(),
    name: this.name,
    email: this.email,
    phone: this.phone,
    prn: this.prn,
    className: this.className,
    division: this.division,
    department: this.department,
    specialization: this.specialization,
    institutionName: this.institutionName,
    currentWeek: this.currentWeek,
    currentModule: this.currentModule,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt,
  };
};

module.exports = mongoose.model('User', userSchema);
