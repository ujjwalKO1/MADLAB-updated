const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { MongoMemoryServer } = require('mongodb-memory-server');

const app = express();
const PORT = 5000;
const JWT_SECRET = 'campus_pulse_secret_key_12345';

app.use(cors());
app.use(express.json());

// Models
const adminSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }
});

const eventSchema = new mongoose.Schema({
  name: { type: String, required: true },
  clubName: { type: String, required: true },
  applicationType: { type: String, required: true },
  formLink: { type: String, required: true },
  imagePath: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const Admin = mongoose.model('Admin', adminSchema);
const Event = mongoose.model('Event', eventSchema);

// Auth Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Access denied. No token provided.' });
  }

  try {
    const verified = jwt.verify(token, JWT_SECRET);
    req.user = verified;
    next();
  } catch (err) {
    res.status(403).json({ error: 'Invalid or expired token.' });
  }
};

// Routes
// 1. Admin Login
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const admin = await Admin.findOne({ email: email.toLowerCase() });
    if (!admin) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    const validPassword = await bcrypt.compare(password, admin.password);
    if (!validPassword) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    const token = jwt.sign({ id: admin._id, email: admin.email }, JWT_SECRET, { expiresIn: '24h' });
    res.json({ token, email: admin.email });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error during login' });
  }
});

// 2. Get All Events (Public)
app.get('/api/events', async (req, res) => {
  try {
    const events = await Event.find().sort({ createdAt: -1 });
    // Map _id to id for Flutter client compatibility
    const formattedEvents = events.map(e => ({
      id: e._id.toString(),
      name: e.name,
      clubName: e.clubName,
      applicationType: e.applicationType,
      formLink: e.formLink,
      imagePath: e.imagePath
    }));
    res.json(formattedEvents);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error retrieving events' });
  }
});

// 3. Create Event (Protected)
app.post('/api/events', authenticateToken, async (req, res) => {
  const { name, clubName, applicationType, formLink, imagePath } = req.body;

  if (!name || !clubName || !applicationType || !formLink || !imagePath) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    const newEvent = new Event({
      name,
      clubName,
      applicationType,
      formLink,
      imagePath
    });

    const savedEvent = await newEvent.save();
    res.status(201).json({
      id: savedEvent._id.toString(),
      name: savedEvent.name,
      clubName: savedEvent.clubName,
      applicationType: savedEvent.applicationType,
      formLink: savedEvent.formLink,
      imagePath: savedEvent.imagePath
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error creating event' });
  }
});

// Start Server with in-memory MongoDB
async function startServer() {
  console.log('Starting in-memory MongoDB server...');
  const mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();
  console.log(`In-memory MongoDB running at: ${mongoUri}`);

  await mongoose.connect(mongoUri);
  console.log('Connected to Mongoose database');

  // Seed default admin
  const hashedAdminPassword = await bcrypt.hash('adminpassword123', 10);
  await Admin.create({
    email: 'admin@college.edu',
    password: hashedAdminPassword
  });
  console.log('Seeded default admin account: admin@college.edu / adminpassword123');

  // Seed default events
  await Event.create([
    {
      name: 'HackFusion 2026',
      clubName: 'Tech Club',
      applicationType: 'Registration',
      formLink: 'https://forms.google.com/hackfusion',
      imagePath: 'assets/images/event_hackathon.png'
    },
    {
      name: 'Rhythm & Beats Fest',
      clubName: 'Music Society',
      applicationType: 'Registration',
      formLink: 'https://forms.google.com/musicfest',
      imagePath: 'assets/images/event_music.png'
    },
    {
      name: 'Campus Marathon 5K',
      clubName: 'Sports Club',
      applicationType: 'Volunteering',
      formLink: 'https://forms.google.com/marathon',
      imagePath: 'assets/images/event_sports.png'
    },
    {
      name: 'Creative Canvas Workshop',
      clubName: 'Art Circle',
      applicationType: 'Volunteering',
      formLink: 'https://forms.google.com/artworkshop',
      imagePath: 'assets/images/event_art.png'
    }
  ]);
  console.log('Seeded initial event data');

  app.listen(PORT, () => {
    console.log(`Server listening on http://localhost:${PORT}`);
  });
}

startServer().catch(err => {
  console.error('Failed to start server:', err);
});
