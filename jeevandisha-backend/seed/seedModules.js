require('dotenv').config();

const mongoose = require('mongoose');
const Module = require('../models/Module');
const Activity = require('../models/Activity');

const modulesData = [
  {
    module: {
      moduleNumber: 1,
      title: 'Understanding Psychological Wellbeing',
      description: 'Foundations of mental wellbeing, emotional literacy, and self-compassion for nursing students.',
      icon: '🌱',
      order: 1,
    },
    activities: [
      {
        title: 'Mental Wellbeing in Nursing',
        type: 'learn',
        order: 1,
        estimatedMinutes: 5,
        learnContent: {
          heading: 'Compassion Starts with Yourself',
          body:
            'Nursing demands immense empathy, clinical precision, and emotional presence. ' +
            'Psychological wellbeing is not the total absence of pressure, but developing self-awareness, ' +
            'emotional grounding, and healthy coping mechanisms to stay resilient through rigorous ward duties and academic milestones.',
          keyIdea: 'You cannot pour from an empty cup; caring for your own mind is essential to patient care.',
        },
      },
      {
        title: 'Recognizing Emotional Fatigue',
        type: 'understand',
        order: 2,
        estimatedMinutes: 4,
        understandContent: {
          scenario:
            'During your first week in the pediatric ward, you feel overwhelmed by a critical patient’s distress and doubt whether you belong in the nursing profession. What is the healthier perspective?',
          options: [
            {
              text: 'Acknowledge that emotional response to suffering is normal, and process these feelings with a mentor or peer.',
              isCorrect: true,
            },
            {
              text: 'Suppress your emotions and assume empathy is a weakness that will hinder clinical efficiency.',
              isCorrect: false,
            },
          ],
          explanation:
            'Emotional sensitivity is a cornerstone of compassionate nursing; learning to process rather than suppress feelings prevents burnout.',
        },
      },
      {
        title: 'Wellbeing Self-Check',
        type: 'practice',
        order: 3,
        estimatedMinutes: 8,
        practiceFields: [
          {
            label: 'What is currently stressing me?',
            placeholder: 'e.g., Upcoming pharmacology viva and night shifts',
          },
          {
            label: 'One thing within my control',
            placeholder: 'e.g., Reviewing 2 drug categories each evening',
          },
          {
            label: 'Person I can talk to',
            placeholder: 'e.g., Senior clinical instructor or hostel roommate',
          },
          {
            label: 'One small sign of progress today',
            placeholder: 'e.g., Successfully placed a cannula with confidence',
          },
        ],
      },
      {
        title: 'Reflecting on Your Nursing Journey',
        type: 'reflect',
        order: 4,
        estimatedMinutes: 7,
        reflectionQuestions: [
          'What motivated you to choose nursing, and how does that purpose inspire you today?',
          'How does your body physically signal when you are carrying too much emotional stress?',
          'What is one self-critical thought you can replace with self-compassion this week?',
        ],
      },
      {
        title: 'Daily Grounding Commitment',
        type: 'apply',
        order: 5,
        estimatedMinutes: 5,
        applyPrompt:
          'Commit to one small grounding habit before entering the hospital ward tomorrow (e.g., 3 deep belly breaths before stepping into handoff).',
      },
    ],
  },
  {
    module: {
      moduleNumber: 2,
      title: 'Stress & Emotional Management',
      description: 'Managing acute stress, emotional regulation, and decompression strategies during intense clinical shifts.',
      icon: '🧘',
      order: 2,
    },
    activities: [
      {
        title: 'The Physiology of Clinical Stress',
        type: 'learn',
        order: 1,
        estimatedMinutes: 5,
        learnContent: {
          heading: 'De-escalating the Sympathetic Surge',
          body:
            'When alarms sound or patient vitals fluctuate rapidly, the sympathetic nervous system triggers the fight-or-flight response. ' +
            'Utilizing physiological sighing and diaphragmatic breathing activates the vagus nerve, lowering heart rate and restoring clear clinical judgment.',
          keyIdea: 'A steady nurse creates a calm environment for critical clinical decisions.',
        },
      },
      {
        title: 'Navigating High-Pressure Moments',
        type: 'understand',
        order: 2,
        estimatedMinutes: 4,
        understandContent: {
          scenario:
            'An emergency admission arrives in the casualty ward simultaneously with three medication administration deadlines. What is your best first action?',
          options: [
            {
              text: 'Take a 5-second breath reset, triage immediate patient safety priorities, and communicate with the charge nurse.',
              isCorrect: true,
            },
            {
              text: 'Rush through medications rapidly without double-checking dosages to save time.',
              isCorrect: false,
            },
          ],
          explanation:
            'Patient safety requires deliberate triage and team communication; rushing increases medication errors.',
        },
      },
      {
        title: 'Stress Decompression Map',
        type: 'practice',
        order: 3,
        estimatedMinutes: 8,
        practiceFields: [
          {
            label: 'What is currently stressing me?',
            placeholder: 'e.g., Fast-paced rounds in the ICU',
          },
          {
            label: 'One thing within my control',
            placeholder: 'e.g., Taking box-breaths between patient assessments',
          },
          {
            label: 'Person I can talk to',
            placeholder: 'e.g., Clinical preceptor sister or batch buddy',
          },
        ],
      },
      {
        title: 'Emotional Processing in Healthcare',
        type: 'reflect',
        order: 4,
        estimatedMinutes: 6,
        reflectionQuestions: [
          'Which clinical procedures cause you the greatest anxiety, and why?',
          'How do you usually release tension after a difficult shift?',
          'What helps you separate your personal life from patient suffering?',
        ],
      },
      {
        title: 'Post-Shift Decompression Ritual',
        type: 'apply',
        order: 5,
        estimatedMinutes: 4,
        applyPrompt:
          'Choose one distinct action to mark the end of your shift today (e.g., washing your hands thoroughly while mindfully leaving ward stress behind).',
      },
    ],
  },
  {
    module: {
      moduleNumber: 3,
      title: 'Self-care, Sleep & Resilience',
      description: 'Circadian rhythm maintenance, restorative sleep, nutrition, and hydration during rotating shift schedules.',
      icon: '🌙',
      order: 3,
    },
    activities: [
      {
        title: 'Restorative Sleep for Shift Workers',
        type: 'learn',
        order: 1,
        estimatedMinutes: 5,
        learnContent: {
          heading: 'Protecting Your Rest Window',
          body:
            'Irregular clinical shifts and night duties disrupt circadian sleep architecture. ' +
            'Prioritizing light hygiene, black-out curtains, consistent post-shift wind-down routines, and proper hydration stabilizes cognitive alertness and protects your immune health.',
          keyIdea: 'Quality sleep is not a luxury for nurses; it is vital clinical safety equipment.',
        },
      },
      {
        title: 'Managing Post-Night Duty Recovery',
        type: 'understand',
        order: 2,
        estimatedMinutes: 4,
        understandContent: {
          scenario:
            'You have just completed an exhausting 12-hour night shift and have an anatomy test in two days. How should you structure your day?',
          options: [
            {
              text: 'Sleep in a dark, quiet room for 6-7 hours first to recover brain function, then study in a focused afternoon block.',
              isCorrect: true,
            },
            {
              text: 'Drink high amounts of energy drinks and stay awake all day studying to avoid falling behind.',
              isCorrect: false,
            },
          ],
          explanation:
            'Sleep deprivation impairs memory consolidation and increases error rates; restful sleep enhances learning retention.',
        },
      },
      {
        title: 'Shift Self-Care Inventory',
        type: 'practice',
        order: 3,
        estimatedMinutes: 8,
        practiceFields: [
          {
            label: 'What is currently stressing me?',
            placeholder: 'e.g., Fatigue and disrupted sleep schedule',
          },
          {
            label: 'One thing within my control',
            placeholder: 'e.g., Creating a dark, quiet sleep sanctuary after shifts',
          },
          {
            label: 'Person I can talk to',
            placeholder: 'e.g., Hostel warden or wellness peer counselor',
          },
          {
            label: 'Daily nourishment goal',
            placeholder: 'e.g., Drink 2L water and pack wholesome fruit/nuts',
          },
        ],
      },
      {
        title: 'Evaluating Personal Energy Reserves',
        type: 'reflect',
        order: 4,
        estimatedMinutes: 6,
        reflectionQuestions: [
          'How does lack of sleep specifically impact your clinical focus and mood?',
          'What habits currently steal your rest before and after hospital duties?',
          'What is one nourishing meal or routine that consistently restores your energy?',
        ],
      },
      {
        title: 'Pre-Sleep Digital Boundary',
        type: 'apply',
        order: 5,
        estimatedMinutes: 5,
        applyPrompt:
          'Set a screen curfew 30 minutes before your next sleep window to give your mind time to decelerate.',
      },
    ],
  },
  {
    module: {
      moduleNumber: 4,
      title: 'Time Management & Study Skills',
      description: 'Balancing clinical postings, academic coursework, case presentations, and personal life without burnout.',
      icon: '📚',
      order: 4,
    },
    activities: [
      {
        title: 'Strategic Learning for Nursing',
        type: 'learn',
        order: 1,
        estimatedMinutes: 5,
        learnContent: {
          heading: 'Active Recall Over Passive Rereading',
          body:
            'Nursing syllabi are vast, spanning anatomy, medical-surgical nursing, and pharmacology. ' +
            'Using structured focus sprints (25-minute Pomodoros), flashcards, and concept-mapping produces superior long-term clinical retention compared to marathon cramming sessions.',
          keyIdea: 'Consistent 25-minute daily active study sessions outperform last-minute all-nighters.',
        },
      },
      {
        title: 'Prioritizing Competing Deadlines',
        type: 'understand',
        order: 2,
        estimatedMinutes: 4,
        understandContent: {
          scenario:
            'You have a care-plan submission tomorrow morning and a clinical skill assessment on Friday. How do you allocate your 3-hour evening window?',
          options: [
            {
              text: 'Dedicate two 45-minute blocks to finish the care plan, take a short break, then spend one 45-minute block practicing procedure steps.',
              isCorrect: true,
            },
            {
              text: 'Multitask by writing the care plan while watching clinical procedure videos with loud music.',
              isCorrect: false,
            },
          ],
          explanation:
            'Single-tasking in dedicated focus sprints maximizes retention and output quality without cognitive overwhelm.',
        },
      },
      {
        title: 'Weekly Focus Planner',
        type: 'practice',
        order: 3,
        estimatedMinutes: 10,
        practiceFields: [
          {
            label: 'What is currently stressing me?',
            placeholder: 'e.g., Care plan deadline and pharmacology exam',
          },
          {
            label: 'One thing within my control',
            placeholder: 'e.g., Blocking 45 minutes of quiet time in library',
          },
          {
            label: 'Person I can talk to',
            placeholder: 'e.g., Study group partner or academic advisor',
          },
        ],
      },
      {
        title: 'Study Habit Reflection',
        type: 'reflect',
        order: 4,
        estimatedMinutes: 6,
        reflectionQuestions: [
          'Where do you lose the most productive study time during clinical duty weeks?',
          'Which nursing subjects do you feel most and least confident in?',
          'How can you integrate quick 5-minute concept reviews into your daily routine?',
        ],
      },
      {
        title: '25-Minute Study Sprint',
        type: 'apply',
        order: 5,
        estimatedMinutes: 25,
        applyPrompt:
          'Execute one uninterrupted 25-minute focus session today on your hardest topic, followed by writing 3 key recall points.',
      },
    ],
  },
  {
    module: {
      moduleNumber: 5,
      title: 'Clinical & Examination Stress',
      description: 'Overcoming viva anxiety, OSCE / practical exam nervousness, and supervisor communication challenges.',
      icon: '🏥',
      order: 5,
    },
    activities: [
      {
        title: 'Mastering Clinical Evaluations & Viva',
        type: 'learn',
        order: 1,
        estimatedMinutes: 5,
        learnContent: {
          heading: 'Confidence Through Mental Rehearsal',
          body:
            'Practical exams (OSCE) and bedside viva assessments induce acute performance anxiety. ' +
            'Visualizing procedure steps in systematic order (SBAR, aseptic techniques, patient consent) builds somatic confidence and stabilizes nervous system trembling.',
          keyIdea: 'Preparation transforms performance anxiety into focused clinical competence.',
        },
      },
      {
        title: 'Handling an Unexpected Examiner Question',
        type: 'understand',
        order: 2,
        estimatedMinutes: 4,
        understandContent: {
          scenario:
            'During a bedside clinical exam, the examiner asks a pharmacology mechanism question that you cannot immediately recall. What is the professional approach?',
          options: [
            {
              text: 'Take a calm breath, articulate the safe clinical principles you know, and calmly state what step you would verify before administering.',
              isCorrect: true,
            },
            {
              text: 'Panic and guess a random dosage without acknowledging uncertainty.',
              isCorrect: false,
            },
          ],
          explanation:
            'Examiners value patient safety, honest professional limits, and calm problem-solving above dangerous guessing.',
        },
      },
      {
        title: 'OSCE & Viva Preparedness Blueprint',
        type: 'practice',
        order: 3,
        estimatedMinutes: 8,
        practiceFields: [
          {
            label: 'What is currently stressing me?',
            placeholder: 'e.g., Tracheostomy suctioning and blood transfusion viva',
          },
          {
            label: 'One thing within my control',
            placeholder: 'e.g., Rehearsing the 5 Rights of Medication Administration',
          },
          {
            label: 'Person I can talk to',
            placeholder: 'e.g., Clinical tutor sister or study partner Ananya',
          },
        ],
      },
      {
        title: 'Exam Anxiety Deconstruction',
        type: 'reflect',
        order: 4,
        estimatedMinutes: 7,
        reflectionQuestions: [
          'What is the worst-case scenario you fear in exams, and how likely or manageable is it in reality?',
          'How have you successfully navigated past challenging academic or clinical hurdles?',
          'What encouraging words would you offer a fellow nursing student facing the same exam?',
        ],
      },
      {
        title: 'Procedure Walkthrough Commitment',
        type: 'apply',
        order: 5,
        estimatedMinutes: 5,
        applyPrompt:
          'Verbally walk through the complete steps of one essential nursing procedure aloud with a peer or in front of a mirror today.',
      },
    ],
  },
];

async function seedModules() {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/jeevandisha';

  console.log('Connecting to MongoDB...');
  await mongoose.connect(uri);
  console.log('Connected to MongoDB.');

  // Delete all existing Module and Activity documents first
  const [deletedActivities, deletedModules] = await Promise.all([
    Activity.deleteMany({}),
    Module.deleteMany({}),
  ]);
  console.log(`Cleared existing data: ${deletedModules.deletedCount} modules and ${deletedActivities.deletedCount} activities deleted.`);

  let totalModules = 0;
  let totalActivities = 0;

  // Insert modules and their linked activities
  for (const item of modulesData) {
    const moduleDoc = await Module.create(item.module);
    totalModules++;

    const activitiesToInsert = item.activities.map((act) => ({
      ...act,
      moduleId: moduleDoc._id,
    }));

    const createdActivities = await Activity.insertMany(activitiesToInsert);
    totalActivities += createdActivities.length;

    console.log(
      `✓ Module ${moduleDoc.moduleNumber}: "${moduleDoc.title}" (${item.module.icon}) with ${createdActivities.length} activities seeded.`
    );
  }

  console.log(`\n🎉 Seed summary: ${totalModules} modules and ${totalActivities} activities successfully seeded!`);
}

async function seedIfEmpty() {
  try {
    const count = await Module.countDocuments();
    if (count === 0) {
      console.log('No modules found in database. Auto-seeding initial curriculum data...');
      let totalActivities = 0;
      for (const item of modulesData) {
        const moduleDoc = await Module.create(item.module);
        const activitiesToInsert = item.activities.map((act) => ({
          ...act,
          moduleId: moduleDoc._id,
        }));
        const created = await Activity.insertMany(activitiesToInsert);
        totalActivities += created.length;
      }
      console.log(`Auto-seeded ${modulesData.length} modules and ${totalActivities} activities.`);
    }
  } catch (err) {
    console.error('Auto-seed error:', err);
  }
}

if (require.main === module) {
  seedModules()
    .then(() => {
      process.exit(0);
    })
    .catch(async (err) => {
      console.error('Seed error:', err);
      await mongoose.disconnect().catch(() => {});
      process.exit(1);
    });
}

module.exports = { seedModules, seedIfEmpty, modulesData };
