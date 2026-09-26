const express = require('express');
const CheckIn = require('../models/CheckIn');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Helper to get today's midnight and tomorrow's midnight
function getTodayMidnightRange() {
  const todayMidnight = new Date();
  todayMidnight.setHours(0, 0, 0, 0);

  const tomorrowMidnight = new Date(todayMidnight);
  tomorrowMidnight.setDate(tomorrowMidnight.getDate() + 1);

  return { todayMidnight, tomorrowMidnight };
}

// @route   POST /api/checkins
// @desc    Create CheckIn with userId and feeling from req.body
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const { feeling, date } = req.body;

    if (!feeling || !String(feeling).trim()) {
      return res.status(400).json({ message: 'Feeling is required' });
    }

    const checkin = await CheckIn.create({
      userId: req.user._id,
      feeling: String(feeling).trim(),
      date: date ? new Date(date) : new Date(),
    });

    return res.status(201).json({
      checkin: checkin.toClient ? checkin.toClient() : checkin,
    });
  } catch (err) {
    console.error('checkin create error:', err);
    return res.status(500).json({ message: 'Failed to create check-in', error: err.message });
  }
});

// @route   GET /api/checkins/today
// @desc    Get today's checkin for the user (date >= today midnight, < tomorrow midnight)
// @access  Private
router.get('/today', protect, async (req, res) => {
  try {
    const { todayMidnight, tomorrowMidnight } = getTodayMidnightRange();

    const checkin = await CheckIn.findOne({
      userId: req.user._id,
      date: { $gte: todayMidnight, $lt: tomorrowMidnight },
    }).sort({ date: -1, createdAt: -1 });

    return res.json({
      checkin: checkin ? (checkin.toClient ? checkin.toClient() : checkin) : null,
    });
  } catch (err) {
    console.error('checkin today error:', err);
    return res.status(500).json({ message: 'Failed to load today check-in', error: err.message });
  }
});

// @route   GET /api/checkins/history
// @desc    Get last 14 checkins for the user sorted desc
// @access  Private
router.get('/history', protect, async (req, res) => {
  try {
    const checkins = await CheckIn.find({ userId: req.user._id })
      .sort({ date: -1, createdAt: -1 })
      .limit(14);

    return res.json({
      checkins: checkins.map((c) => (c.toClient ? c.toClient() : c)),
    });
  } catch (err) {
    console.error('checkins history error:', err);
    return res.status(500).json({ message: 'Failed to load check-ins history', error: err.message });
  }
});

// @route   GET /api/checkins
// @desc    Get list of checkins for user
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const checkins = await CheckIn.find({ userId: req.user._id })
      .sort({ date: -1, createdAt: -1 })
      .limit(30);

    return res.json({
      checkins: checkins.map((c) => (c.toClient ? c.toClient() : c)),
    });
  } catch (err) {
    console.error('checkins list error:', err);
    return res.status(500).json({ message: 'Failed to load check-ins', error: err.message });
  }
});

module.exports = router;
