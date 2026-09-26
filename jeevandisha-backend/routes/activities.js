const express = require('express');
const Activity = require('../models/Activity');
const ActivityResponse = require('../models/ActivityResponse');
const Module = require('../models/Module');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Helper to check and advance user module upon completing all module activities
async function maybeAdvanceUser(user, activity) {
  try {
    const moduleDoc = await Module.findById(activity.moduleId);
    if (!moduleDoc) return;

    const activities = await Activity.find({ moduleId: moduleDoc._id });
    const completed = await ActivityResponse.countDocuments({
      userId: user._id,
      activityId: { $in: activities.map((a) => a._id) },
      status: 'completed',
    });

    if (completed >= activities.length) {
      const nextModule = Math.min(5, (moduleDoc.moduleNumber || 1) + 1);
      if (nextModule > (user.currentModule || 1)) {
        user.currentModule = nextModule;
        await user.save();
      }
    }
  } catch (err) {
    console.error('maybeAdvanceUser error:', err);
  }
}

// @route   GET /api/activities/:id
// @desc    Get one activity by id
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const activity = await Activity.findById(req.params.id);
    if (!activity) {
      return res.status(404).json({ message: 'Activity not found' });
    }

    const response = await ActivityResponse.findOne({
      userId: req.user._id,
      activityId: activity._id,
    });

    return res.json({
      activity: activity.toClient ? activity.toClient(response) : activity,
      response: response ? (response.toClient ? response.toClient() : response) : null,
    });
  } catch (err) {
    console.error('activity get error:', err);
    return res.status(500).json({ message: 'Failed to load activity', error: err.message });
  }
});

// @route   POST /api/activities/:id/start
// @desc    Start an activity (create ActivityResponse with in_progress status)
// @access  Private
router.post('/:id/start', protect, async (req, res) => {
  try {
    const activity = await Activity.findById(req.params.id);
    if (!activity) {
      return res.status(404).json({ message: 'Activity not found' });
    }

    // Check if an ActivityResponse already exists for this user and activity
    let response = await ActivityResponse.findOne({
      userId: req.user._id,
      activityId: activity._id,
    });

    if (response) {
      // Return existing doc if already started/completed
      return res.status(200).json({
        response: response.toClient ? response.toClient() : response,
      });
    }

    // Create new ActivityResponse document
    response = await ActivityResponse.create({
      userId: req.user._id,
      activityId: activity._id,
      status: 'in_progress',
      startedAt: new Date(),
    });

    return res.status(201).json({
      response: response.toClient ? response.toClient() : response,
    });
  } catch (err) {
    console.error('activity start error:', err);
    return res.status(500).json({ message: 'Failed to start activity', error: err.message });
  }
});

// @route   POST /api/activities/:id/complete
// @desc    Complete an activity with practice, reflection, and apply responses
// @access  Private
router.post('/:id/complete', protect, async (req, res) => {
  try {
    const activity = await Activity.findById(req.params.id);
    if (!activity) {
      return res.status(404).json({ message: 'Activity not found' });
    }

    let response = await ActivityResponse.findOne({
      userId: req.user._id,
      activityId: activity._id,
    });

    if (!response) {
      response = new ActivityResponse({
        userId: req.user._id,
        activityId: activity._id,
        startedAt: new Date(),
      });
    }

    // Update responses from req.body
    if (req.body?.practiceResponses && typeof req.body.practiceResponses === 'object') {
      for (const [key, value] of Object.entries(req.body.practiceResponses)) {
        response.practiceResponses.set(key, String(value ?? ''));
      }
    }

    if (req.body?.reflectionResponses && typeof req.body.reflectionResponses === 'object') {
      for (const [key, value] of Object.entries(req.body.reflectionResponses)) {
        response.reflectionResponses.set(key, String(value ?? ''));
      }
    }

    if (req.body?.applyResponse !== undefined) {
      response.applyResponse = String(req.body.applyResponse ?? '');
    }

    response.status = 'completed';
    response.completedAt = new Date();
    await response.save();

    await maybeAdvanceUser(req.user, activity);

    return res.status(200).json({
      message: 'Activity completed',
      response: response.toClient ? response.toClient() : response,
      activity: activity.toClient ? activity.toClient(response) : activity,
    });
  } catch (err) {
    console.error('activity complete error:', err);
    return res.status(500).json({ message: 'Failed to complete activity', error: err.message });
  }
});

// @route   GET /api/activities/:id/response
// @desc    Get user's response for a specific activity
// @access  Private
router.get('/:id/response', protect, async (req, res) => {
  try {
    const response = await ActivityResponse.findOne({
      userId: req.user._id,
      activityId: req.params.id,
    });

    if (!response) {
      return res.json({ response: null });
    }

    return res.json({
      response: response.toClient ? response.toClient() : response,
    });
  } catch (err) {
    console.error('activity response get error:', err);
    return res.status(500).json({ message: 'Failed to load activity response', error: err.message });
  }
});

// @route   POST /api/activities/:id/response
// @desc    Save draft or in-progress response
// @access  Private
router.post('/:id/response', protect, async (req, res) => {
  try {
    const activity = await Activity.findById(req.params.id);
    if (!activity) {
      return res.status(404).json({ message: 'Activity not found' });
    }

    let response = await ActivityResponse.findOne({
      userId: req.user._id,
      activityId: activity._id,
    });

    if (!response) {
      response = new ActivityResponse({
        userId: req.user._id,
        activityId: activity._id,
        startedAt: new Date(),
        status: 'in_progress',
      });
    }

    const {
      practiceResponses,
      reflectionResponses,
      applyResponse,
      status,
    } = req.body;

    if (practiceResponses && typeof practiceResponses === 'object') {
      for (const [key, value] of Object.entries(practiceResponses)) {
        response.practiceResponses.set(key, String(value ?? ''));
      }
    }
    if (reflectionResponses && typeof reflectionResponses === 'object') {
      for (const [key, value] of Object.entries(reflectionResponses)) {
        response.reflectionResponses.set(key, String(value ?? ''));
      }
    }
    if (applyResponse !== undefined) {
      response.applyResponse = String(applyResponse ?? '');
    }
    if (status === 'in_progress' || status === 'completed') {
      response.status = status;
      if (status === 'completed') {
        response.completedAt = new Date();
      }
    }

    await response.save();

    if (response.status === 'completed') {
      await maybeAdvanceUser(req.user, activity);
    }

    return res.json({
      response: response.toClient ? response.toClient() : response,
      activity: activity.toClient ? activity.toClient(response) : activity,
    });
  } catch (err) {
    console.error('activity response save error:', err);
    return res.status(500).json({ message: 'Failed to save response', error: err.message });
  }
});

module.exports = router;
