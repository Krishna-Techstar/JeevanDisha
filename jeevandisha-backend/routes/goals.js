const express = require('express');
const Goal = require('../models/Goal');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/', protect, async (req, res) => {
  try {
    const goals = await Goal.find({ userId: req.user._id }).sort({
      createdAt: -1,
    });
    return res.json({ goals: goals.map((g) => g.toClient()) });
  } catch (err) {
    console.error('goals list error:', err);
    return res.status(500).json({ message: 'Failed to load goals' });
  }
});

router.post('/', protect, async (req, res) => {
  try {
    const {
      goal,
      action = '',
      schedule = '',
      targetDate,
      firstStep = '',
      status = 'active',
      // Flutter may still send title
      title,
    } = req.body;

    const goalText = (goal || title || '').toString().trim();
    if (!goalText) {
      return res.status(400).json({ message: 'goal is required' });
    }

    const doc = await Goal.create({
      userId: req.user._id,
      goal: goalText,
      action: String(action || ''),
      schedule: String(schedule || ''),
      targetDate: targetDate ? new Date(targetDate) : null,
      firstStep: String(firstStep || ''),
      status: status === 'completed' ? 'completed' : 'active',
    });

    return res.status(201).json({ goal: doc.toClient() });
  } catch (err) {
    console.error('goal create error:', err);
    return res.status(500).json({ message: 'Failed to create goal' });
  }
});

router.put('/:id', protect, async (req, res) => {
  try {
    const doc = await Goal.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });
    if (!doc) {
      return res.status(404).json({ message: 'Goal not found' });
    }

    const fields = ['goal', 'action', 'schedule', 'firstStep', 'status'];
    for (const key of fields) {
      if (req.body[key] !== undefined) doc[key] = req.body[key];
    }
    if (req.body.title !== undefined) doc.goal = req.body.title;
    if (req.body.completed === true) doc.status = 'completed';
    if (req.body.completed === false) doc.status = 'active';
    if (req.body.targetDate !== undefined) {
      doc.targetDate = req.body.targetDate
        ? new Date(req.body.targetDate)
        : null;
    }

    await doc.save();
    return res.json({ goal: doc.toClient() });
  } catch (err) {
    console.error('goal update error:', err);
    return res.status(500).json({ message: 'Failed to update goal' });
  }
});

router.delete('/:id', protect, async (req, res) => {
  try {
    const deleted = await Goal.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id,
    });
    if (!deleted) {
      return res.status(404).json({ message: 'Goal not found' });
    }
    return res.json({ message: 'Goal deleted' });
  } catch (err) {
    console.error('goal delete error:', err);
    return res.status(500).json({ message: 'Failed to delete goal' });
  }
});

module.exports = router;
