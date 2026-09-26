const express = require('express');
const Activity = require('../models/Activity');
const ActivityResponse = require('../models/ActivityResponse');
const Goal = require('../models/Goal');
const StudySession = require('../models/StudySession');
const CheckIn = require('../models/CheckIn');
const Module = require('../models/Module');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Helper to compute past 7 days timestamp
function weekAgo() {
  const d = new Date();
  d.setDate(d.getDate() - 7);
  return d;
}

// @route   GET /api/progress
// @desc    Get aggregated user progress metrics
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const userId = req.user._id;
    const weekStart = weekAgo();

    // Parallel queries via Promise.all
    const [
      completedActivities,
      totalActivities,
      completedStudySessions,
      completedGoals,
      totalCheckIns,
      weekSessions,
      allGoals,
      modules,
      userResponses,
    ] = await Promise.all([
      ActivityResponse.countDocuments({ userId, status: 'completed' }),
      Activity.countDocuments(),
      StudySession.countDocuments({ userId, status: 'completed' }),
      Goal.countDocuments({ userId, status: 'completed' }),
      CheckIn.countDocuments({ userId }),
      StudySession.find({
        userId,
        status: 'completed',
        completedAt: { $gte: weekStart },
      }),
      Goal.find({ userId }),
      Module.find().sort({ moduleNumber: 1 }),
      ActivityResponse.find({ userId, status: 'completed' }).select('activityId'),
    ]);

    const weeklyMinutes = weekSessions.reduce(
      (sum, s) => sum + (s.duration || 0),
      0
    );

    const overall =
      totalActivities === 0 ? 0 : completedActivities / totalActivities;

    const completedIds = new Set(
      userResponses.map((r) => r.activityId.toString())
    );

    const moduleProgress = {};
    for (const mod of modules) {
      const acts = await Activity.find({ moduleId: mod._id }).select('_id');
      const done = acts.filter((a) => completedIds.has(a._id.toString())).length;
      moduleProgress[mod._id.toString()] =
        acts.length === 0 ? 0 : done / acts.length;
    }

    const currentWeek = req.user.currentWeek || 1;
    const currentModule = req.user.currentModule || 1;

    return res.json({
      completedActivities,
      totalActivities,
      completedStudySessions,
      completedGoals,
      totalCheckIns,
      currentWeek,
      currentModule,
      // Nested object for Flutter client compatibility
      progress: {
        overall,
        activitiesCompleted: completedActivities,
        activitiesTotal: totalActivities,
        goalsCompleted: completedGoals,
        goalsTotal: allGoals.length,
        currentWeek,
        currentModule,
        weeklyMinutes,
        totalCheckIns,
        moduleProgress,
      },
    });
  } catch (err) {
    console.error('progress error:', err);
    return res.status(500).json({ message: 'Failed to load progress', error: err.message });
  }
});

module.exports = router;
