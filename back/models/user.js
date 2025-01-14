const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const UserSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  resetCode: { type: String },
  resetCodeExpires: { type: Date },
  ratings: [
    {
      rater: { type: mongoose.Schema.Types.ObjectId, ref: 'users' },
      score: { type: Number, required: true, min: 1, max: 5 },
    },
  ],
  averageRating: { type: Number, default: 0 },
});

// Middleware to hash passwords before saving
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});


module.exports = mongoose.model('users', UserSchema);
