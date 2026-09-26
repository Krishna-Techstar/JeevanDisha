const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Helper to sign JWT
const signToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: '7d',
  });
};

// @route   POST /register
// @desc    Register a new user
// @access  Public
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validate that name, email, and password are all present
    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Name, email, and password are required' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Check that no existing user has that email
    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // Hash password with bcryptjs saltRounds 10
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Create and save new User document
    const user = await User.create({
      name: name.trim(),
      email: normalizedEmail,
      passwordHash,
      phone: req.body.phone ? String(req.body.phone).trim() : '',
      prn: req.body.prn ? String(req.body.prn).trim().toUpperCase() : '',
      className: req.body.className ? String(req.body.className).trim() : '',
      division: req.body.division ? String(req.body.division).trim() : '',
      department: req.body.department ? String(req.body.department).trim() : '',
      specialization: req.body.specialization ? String(req.body.specialization).trim() : '',
      institutionName: req.body.institutionName ? String(req.body.institutionName).trim() : '',
      currentWeek: 1,
      currentModule: 1,
    });

    // Sign JWT with payload { id: user._id }
    const token = signToken(user._id);

    // Return 201 with { token, user: { id: user._id, name, email, currentWeek, currentModule } }
    return res.status(201).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        currentWeek: user.currentWeek,
        currentModule: user.currentModule,
      },
    });
  } catch (err) {
    console.error('Registration error:', err);
    return res.status(500).json({ message: 'Server error during registration', error: err.message });
  }
});

// @route   POST /login
// @desc    Authenticate user & get token
// @access  Public
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate email and password are present
    if (!email || !password) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Find user by email
    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Compare password with bcrypt.compare
    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Sign same JWT
    const token = signToken(user._id);

    // Return 200 with { token, user: { id: user._id, name, email, currentWeek, currentModule } }
    return res.status(200).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        currentWeek: user.currentWeek,
        currentModule: user.currentModule,
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ message: 'Server error during login', error: err.message });
  }
});

// @route   GET /me
// @desc    Get current user profile
// @access  Private
router.get('/me', protect, async (req, res) => {
  return res.json({ user: req.user.toSafeJSON() });
});

// @route   PATCH /progress
// @desc    Update user progress
// @access  Private
router.patch('/progress', protect, async (req, res) => {
  try {
    const { currentWeek, currentModule } = req.body;
    if (currentWeek !== undefined) {
      req.user.currentWeek = Math.min(6, Math.max(1, Number(currentWeek)));
    }
    if (currentModule !== undefined) {
      req.user.currentModule = Math.min(5, Math.max(1, Number(currentModule)));
    }
    await req.user.save();
    return res.json({ user: req.user.toSafeJSON() });
  } catch (err) {
    console.error('Progress update error:', err);
    return res.status(500).json({ message: 'Failed to update progress' });
  }
});

module.exports = router;
