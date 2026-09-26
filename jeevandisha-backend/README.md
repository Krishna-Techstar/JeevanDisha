# JeevanDisha Backend

Express + MongoDB API for the JeevanDisha Flutter app.

## Setup

1. Start MongoDB locally  
2. Configure `.env` (see `.env.example`)  
3. `npm install`  
4. **`npm run seed`** — loads 5 modules × 5 activities (learn → apply)  
5. `npm run dev` — `http://localhost:5000`

## Collections / schemas

| Collection | Key fields |
|------------|------------|
| `users` | name, email, phone, prn, className, division, department, specialization, institutionName, passwordHash, currentWeek, currentModule |
| `modules` | moduleNumber (1–5), title, description, icon (emoji), order |
| `activities` | moduleId, title, type (`learn`/`understand`/`practice`/`reflect`/`apply`), typed content blocks, estimatedMinutes |
| `activityresponses` | userId, activityId, practiceResponses, reflectionResponses, applyResponse, status |
| `goals` | userId, goal, action, schedule, targetDate, firstStep, status |
| `studysessions` | userId, topic, duration, recallPoints[3], status |
| `checkins` | userId, feeling, date |
| `selfcareentries` | userId, water/meals/physicalActivity/relaxation/socialConnection/sleep, date |

## Auth

- `POST /api/auth/register` — requires `name`, `email`, `password`, `prn` (+ optional academic fields)
- `POST /api/auth/login` — `email` or `prn` + `password`
- Password stored as `passwordHash` (bcrypt)
