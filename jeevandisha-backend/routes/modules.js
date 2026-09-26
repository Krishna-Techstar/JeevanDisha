const express = require('express');
const Module = require('../models/Module');
const Activity = require('../models/Activity');
const ActivityResponse = require('../models/ActivityResponse');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Helper to attach user progress and activities to module client response
async function formatModuleWithProgress(moduleDoc, userId) {
  const activities = await Activity.find({ moduleId: moduleDoc._id }).sort({
    order: 1,
  });

  const responses = await ActivityResponse.find({
    userId,
    activityId: { $in: activities.map((a) => a._id) },
  });
  const responseMap = new Map(
    responses.map((r) => [r.activityId.toString(), r])
  );

  const mappedActivities = activities.map((a) =>
    a.toClient ? a.toClient(responseMap.get(a._id.toString()) || null) : a
  );
  const completedCount = mappedActivities.filter(
    (a) => a.completed || a.status === 'completed'
  ).length;
  const progress =
    mappedActivities.length === 0 ? 0 : completedCount / mappedActivities.length;

  if (moduleDoc.toClient) {
    return moduleDoc.toClient({ progress, activities: mappedActivities });
  }

  return {
    ...moduleDoc.toObject(),
    progress,
    activities: mappedActivities,
  };
}

// @route   GET /api/modules
// @desc    Get all modules sorted by order
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const modules = await Module.find().sort({ order: 1, moduleNumber: 1 });
    const formatted = await Promise.all(
      modules.map((m) => formatModuleWithProgress(m, req.user._id))
    );
    return res.json({ modules: formatted });
  } catch (err) {
    console.error('modules list error:', err);
    return res.status(500).json({ message: 'Failed to load modules', error: err.message });
  }
});

// @route   GET /api/modules/:id
// @desc    Get one module by id
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const moduleDoc = await Module.findById(req.params.id);
    if (!moduleDoc) {
      return res.status(404).json({ message: 'Module not found' });
    }

    const formatted = await formatModuleWithProgress(moduleDoc, req.user._id);
    return res.json({ module: formatted });
  } catch (err) {
    console.error('module get error:', err);
    return res.status(500).json({ message: 'Failed to load module', error: err.message });
  }
});

// @route   GET /api/modules/:id/activities
// @desc    Get all activities for that module sorted by order
// @access  Private
router.get('/:id/activities', protect, async (req, res) => {
  try {
    const moduleDoc = await Module.findById(req.params.id);
    if (!moduleDoc) {
      return res.status(404).json({ message: 'Module not found' });
    }

    const activities = await Activity.find({ moduleId: moduleDoc._id }).sort({
      order: 1,
    });

    const responses = await ActivityResponse.find({
      userId: req.user._id,
      activityId: { $in: activities.map((a) => a._id) },
    });
    const responseMap = new Map(
      responses.map((r) => [r.activityId.toString(), r])
    );

    const formattedActivities = activities.map((a) =>
      a.toClient ? a.toClient(responseMap.get(a._id.toString()) || null) : a
    );

    return res.json({ activities: formattedActivities });
  } catch (err) {
    console.error('module activities error:', err);
    return res.status(500).json({ message: 'Failed to load module activities', error: err.message });
  }
});

module.exports = router;
