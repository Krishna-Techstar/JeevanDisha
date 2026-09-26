const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * JWT Authentication Middleware
 * Reads the Authorization header, verifies the token, finds the user, and attaches to req.user.
 */
const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || req.headers.Authorization;

    // Check if authorization header is provided and formatted as "Bearer <token>"
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return res.status(401).json({ message: 'No token provided' });
    }

    // Verify JWT token
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      return res.status(401).json({ message: 'Invalid token' });
    }

    // Find user by decoded ID
    const user = await User.findById(decoded.id);
    if (!user) {
      return res.status(401).json({ message: 'User not found' });
    }

    // Attach user document to request object
    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

module.exports = protect;
module.exports.protect = protect;
module.exports.auth = protect;
