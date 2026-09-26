const express = require('express');
const SelfCare = require('../models/SelfCare');
const { protect } = require('../middleware/auth');

const router = express.Router();

const SELFCARE_FIELDS = [
  'water',
  'meals',
  'physicalActivity',
  'relaxation',
  'socialConnection',
  'sleep',
];

// Helper to get today's midnight and tomorrow's midnight
function getTodayMidnightRange() {
  const todayMidnight = new Date();
  todayMidnight.setHours(0, 0, 0, 0);

  const tomorrowMidnight = new Date(todayMidnight);
  tomorrowMidnight.setDate(tomorrowMidnight.getDate() + 1);

  return { todayMidnight, tomorrowMidnight };
}

// @route   POST /api/selfcare
// @desc    Create or update today's SelfCare entry for user (upsert with findOneAndUpdate)
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const { todayMidnight, tomorrowMidnight } = getTodayMidnightRange();

    const updateFields = {};
    for (const field of SELFCARE_FIELDS) {
      if (req.body[field] !== undefined) {
        updateFields[field] = Boolean(req.body[field]);
      }
    }

    const entry = await SelfCare.findOneAndUpdate(
      {
        userId: req.user._id,
        date: { $gte: todayMidnight, $lt: tomorrowMidnight },
      },
      {
        $set: updateFields,
        $setOnInsert: {
          userId: req.user._id,
          date: req.body.date ? new Date(req.body.date) : new Date(),
        },
      },
      {
        upsert: true,
        new: true,
        setDefaultsOnInsert: true,
      }
    );

    return res.status(200).json({
      selfcare: entry.toClient ? entry.toClient() : entry,
    });
  } catch (err) {
    console.error('selfcare upsert error:', err);
    return res.status(500).json({ message: 'Failed to save self-care entry', error: err.message });
  }
});

// @route   GET /api/selfcare/today
// @desc    Get today's selfcare entry for user
// @access  Private
router.get('/today', protect, async (req, res) => {
  try {
    const { todayMidnight, tomorrowMidnight } = getTodayMidnightRange();

    const entry = await SelfCare.findOne({
      userId: req.user._id,
      date: { $gte: todayMidnight, $lt: tomorrowMidnight },
    }).sort({ date: -1 });

    return res.json({
      selfcare: entry ? (entry.toClient ? entry.toClient() : entry) : null,
    });
  } catch (err) {
    console.error('selfcare today error:', err);
    return res.status(500).json({ message: 'Failed to load today self-care entry', error: err.message });
  }
});

// @route   GET /api/selfcare
// @desc    Get history of self-care entries
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const items = await SelfCare.find({ userId: req.user._id })
      .sort({ date: -1 })
      .limit(30);

    return res.json({
      selfcare: items.map((s) => (s.toClient ? s.toClient() : s)),
    });
  } catch (err) {
    console.error('selfcare list error:', err);
    return res.status(500).json({ message: 'Failed to load self-care entries', error: err.message });
  }
});

module.exports = router;
