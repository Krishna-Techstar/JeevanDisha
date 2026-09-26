const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

// Configure environment variables
dotenv.config();

// Initialize Express App for JEEVANDISHA
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Import Routes
const authRoutes = require('./routes/auth');
const modulesRoutes = require('./routes/modules');
const activitiesRoutes = require('./routes/activities');
const goalsRoutes = require('./routes/goals');
const studyRoutes = require('./routes/study');
const checkinsRoutes = require('./routes/checkins');
const selfcareRoutes = require('./routes/selfcare');
const progressRoutes = require('./routes/progress');
const dashboardRoutes = require('./routes/dashboard');

// Health Check Route
app.get('/api/health', (_req, res) => {
  res.json({ ok: true, app: 'JEEVANDISHA', service: 'jeevandisha-backend' });
});

// Mount Routes
app.use('/api/auth', authRoutes);
app.use('/api/modules', modulesRoutes);
app.use('/api/activities', activitiesRoutes);
app.use('/api/goals', goalsRoutes);
app.use('/api/study', studyRoutes);
app.use('/api/checkins', checkinsRoutes);
app.use('/api/selfcare', selfcareRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/dashboard', dashboardRoutes);

// Global Error Handler
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ message: 'Internal server error' });
});

// Database Connection & Initialization
const { seedIfEmpty } = require('./seed/seedModules');
let mongod = null;

async function connectDatabase() {
  const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/jeevandisha';
  
  try {
    await mongoose.connect(MONGODB_URI, { serverSelectionTimeoutMS: 3000 });
    console.log(`MongoDB connected: ${MONGODB_URI}`);
    await seedIfEmpty();
  } catch (err) {
    console.warn(`Local MongoDB connection failed (${err.message}). Initializing MongoMemoryServer...`);
    try {
      const { MongoMemoryServer } = require('mongodb-memory-server');
      mongod = await MongoMemoryServer.create();
      const memUri = mongod.getUri();
      await mongoose.connect(memUri);
      console.log(`MongoDB connected via MongoMemoryServer: ${memUri}`);
      await seedIfEmpty();
    } catch (memErr) {
      console.error('Fatal MongoDB connection error:', memErr);
    }
  }
}

connectDatabase();

// Server Listener
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
