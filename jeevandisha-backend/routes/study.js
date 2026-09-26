const express = require('express');
const StudySession = require('../models/StudySession');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/', protect, async (req, res) => {
  try {
    const sessions = await StudySession.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .limit(50);
    return res.json({ sessions: sessions.map((s) => s.toClient()) });
  } catch (err) {
    console.error('study list error:', err);
    return res.status(500).json({ message: 'Failed to load study sessions' });
  }
});

router.post('/start', protect, async (req, res) => {
  try {
    const { topic = 'Focus session', duration = 25 } = req.body;
    const session = await StudySession.create({
      userId: req.user._id,
      topic: String(topic || 'Focus session').trim(),
      duration: Number(duration) || 25,
      status: 'in_progress',
      startedAt: new Date(),
    });
    return res.status(201).json({
      sessionId: session._id.toString(),
      id: session._id.toString(),
      session: session.toClient ? session.toClient() : session,
    });
  } catch (err) {
    console.error('study start error:', err);
    return res.status(500).json({ message: 'Failed to start study session' });
  }
});

router.post('/:id/complete', protect, async (req, res) => {
  try {
    const session = await StudySession.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });
    if (!session) {
      return res.status(404).json({ message: 'Study session not found' });
    }

    if (req.body.recallPoints && Array.isArray(req.body.recallPoints)) {
      session.recallPoints = req.body.recallPoints.map(String).slice(0, 3);
    }
    if (req.body.duration !== undefined) {
      session.duration = Number(req.body.duration);
    }
    if (req.body.topic !== undefined) {
      session.topic = String(req.body.topic).trim();
    }

    session.status = 'completed';
    session.completedAt = new Date();
    await session.save();

    return res.json({
      sessionId: session._id.toString(),
      session: session.toClient ? session.toClient() : session,
    });
  } catch (err) {
    console.error('study complete error:', err);
    return res.status(500).json({ message: 'Failed to complete study session' });
  }
});

router.post('/', protect, async (req, res) => {
  try {
    const {
      topic,
      duration = 25,
      recallPoints = [],
      status = 'in_progress',
    } = req.body;

    if (!topic || !String(topic).trim()) {
      return res.status(400).json({ message: 'topic is required' });
    }

    const points = Array.isArray(recallPoints)
      ? recallPoints.map(String).slice(0, 3)
      : [];

    if (points.length > 0 && points.length !== 3) {
      return res
        .status(400)
        .json({ message: 'recallPoints must contain exactly 3 items' });
    }

    const session = await StudySession.create({
      userId: req.user._id,
      topic: String(topic).trim(),
      duration: Number(duration) || 25,
      recallPoints: points,
      status: status === 'completed' ? 'completed' : 'in_progress',
      startedAt: new Date(),
      completedAt: status === 'completed' ? new Date() : null,
    });

    return res.status(201).json({ session: session.toClient() });
  } catch (err) {
    console.error('study create error:', err);
    return res.status(500).json({ message: 'Failed to create study session' });
  }
});

router.put('/:id/complete', protect, async (req, res) => {
  try {
    const session = await StudySession.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });
    if (!session) {
      return res.status(404).json({ message: 'Study session not found' });
    }

    if (req.body.recallPoints) {
      const points = req.body.recallPoints.map(String);
      if (points.length !== 3) {
        return res
          .status(400)
          .json({ message: 'recallPoints must contain exactly 3 items' });
      }
      session.recallPoints = points;
    }
    if (req.body.duration !== undefined) {
      session.duration = Number(req.body.duration);
    }
    if (req.body.topic !== undefined) {
      session.topic = String(req.body.topic).trim();
    }

    session.status = 'completed';
    session.completedAt = new Date();
    await session.save();

    return res.json({ session: session.toClient() });
  } catch (err) {
    console.error('study complete error:', err);
    return res.status(500).json({ message: 'Failed to complete study session' });
  }
});

module.exports = router;
