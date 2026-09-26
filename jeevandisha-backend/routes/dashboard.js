const express = require('express');
const Module = require('../models/Module');
const Activity = require('../models/Activity');
const ActivityResponse = require('../models/ActivityResponse');
const Goal = require('../models/Goal');
const StudySession = require('../models/StudySession');
const CheckIn = require('../models/CheckIn');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Helper to get today's midnight range
function getTodayMidnightRange() {
  const todayMidnight = new Date();
  todayMidnight.setHours(0, 0, 0, 0);

  const tomorrowMidnight = new Date(todayMidnight);
  tomorrowMidnight.setDate(tomorrowMidnight.getDate() + 1);

  return { todayMidnight, tomorrowMidnight };
}

// @route   GET /api/dashboard
// @desc    Get aggregated dashboard data powering the home screen
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const userId = req.user._id;
    const { todayMidnight, tomorrowMidnight } = getTodayMidnightRange();
    const currentModuleNumber = req.user.currentModule || 1;

    // Helper task to query current module, activities, and first incomplete activity
    const getModuleAndTodayActivity = async () => {
      const moduleDoc = await Module.findOne({ moduleNumber: currentModuleNumber });
      if (!moduleDoc) {
        return { currentModule: null, todayActivity: null };
      }

      const [activities, completedResponses] = await Promise.all([
        Activity.find({ moduleId: moduleDoc._id }).sort({ order: 1 }),
        ActivityResponse.find({ userId, status: 'completed' }).select('activityId'),
      ]);

      const completedIds = new Set(
        completedResponses.map((r) => r.activityId.toString())
      );

      const firstIncomplete = activities.find(
        (a) => !completedIds.has(a._id.toString())
      );

      const selected = firstIncomplete || activities[0] || null;
      const todayActivity = selected
        ? (selected.toClient
            ? selected.toClient()
            : {
                id: selected._id.toString(),
                moduleId: selected.moduleId.toString(),
                title: selected.title,
                type: selected.type,
                order: selected.order,
                estimatedMinutes: selected.estimatedMinutes,
              })
        : null;

      return {
        currentModule: {
          id: moduleDoc._id.toString(),
          title: moduleDoc.title,
          icon: moduleDoc.icon,
          description: moduleDoc.description,
        },
        todayActivity,
      };
    };

    // Run queries in parallel via Promise.all
    const [
      moduleAndActivity,
      activeGoal,
      todayCheckIn,
      completedActivities,
      totalActivities,
      completedStudySessions,
      completedGoals,
    ] = await Promise.all([
      getModuleAndTodayActivity(),
      Goal.findOne({ userId, status: 'active' }).sort({ createdAt: -1 }),
      CheckIn.findOne({
        userId,
        date: { $gte: todayMidnight, $lt: tomorrowMidnight },
      }).sort({ date: -1, createdAt: -1 }),
      ActivityResponse.countDocuments({ userId, status: 'completed' }),
      Activity.countDocuments(),
      StudySession.countDocuments({ userId, status: 'completed' }),
      Goal.countDocuments({ userId, status: 'completed' }),
    ]);

    const { currentModule, todayActivity } = moduleAndActivity;

    return res.json({
      user: {
        name: req.user.name,
        currentWeek: req.user.currentWeek || 1,
        currentModule: req.user.currentModule || 1,
      },
      currentModule: currentModule || {
        title: `Module ${currentModuleNumber}`,
        icon: '📘',
        description: '',
      },
      todayActivity: todayActivity || null,
      todayGoal: activeGoal
        ? (activeGoal.toClient
            ? activeGoal.toClient()
            : {
                id: activeGoal._id.toString(),
                goal: activeGoal.goal,
                action: activeGoal.action,
                schedule: activeGoal.schedule,
                targetDate: activeGoal.targetDate,
                firstStep: activeGoal.firstStep,
                status: activeGoal.status,
                createdAt: activeGoal.createdAt,
              })
        : null,
      todayCheckIn: todayCheckIn
        ? (todayCheckIn.toClient
            ? todayCheckIn.toClient()
            : {
                id: todayCheckIn._id.toString(),
                feeling: todayCheckIn.feeling,
                date: todayCheckIn.date || todayCheckIn.createdAt,
              })
        : null,
      progress: {
        completedActivities,
        totalActivities,
        completedStudySessions,
        completedGoals,
      },
    });
  } catch (err) {
    console.error('dashboard error:', err);
    return res.status(500).json({ message: 'Failed to load dashboard data', error: err.message });
  }
});

module.exports = router;
