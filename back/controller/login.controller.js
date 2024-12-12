const User = require('../models/login.model.js');
const jwt = require('jsonwebtoken');

// Register new user
exports.register = async (req, res) => {
  const { username, email, phoneNumber, birthdate, password, confirmPassword } = req.body;

  // Validate fields
  if (!username || !email || !phoneNumber || !birthdate || !password || !confirmPassword) {
    return res.status(400).json({ error: 'All fields are required.' });
  }

  if (password !== confirmPassword) {
    return res.status(400).json({ error: 'Passwords do not match.' });
  }

  try {
    // Create new user
    const user = new User({
      username,
      email,
      phoneNumber,
      birthdate,
      password, // Assume password hashing is handled in the model
    });

    await user.save();
    res.status(201).json({ message: 'User registered successfully!' });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ error: 'Email already exists.' });
    }
    res.status(500).json({ error: 'Server error.' });
  }
};

// Login user
exports.login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required.' });
  }

  try {
    // Find the user by email
    const user = await User.findOne({ email: { $regex: new RegExp(`^${email}$`, 'i') } });
    if (!user) {
      return res.status(400).json({ error: 'Invalid email or password.' });
    }

    // Check if the password matches
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid email or password.' });
    }

    // Include necessary user details in the JWT payload
    const payload = {
      id: user._id, // User ID
      username: user.username, // Username
      email: user.email, // Email
    };

    // Generate a JWT
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '1h' });

    res.status(200).json({
      message: 'Login successful.',
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
      },
    });
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ error: 'Server error.' });
  }
};


exports.rateUser = async (req, res) => {
  try {
    const { sellerId, score } = req.body;

    if (!sellerId || !score) {
      return res.status(400).json({ message: 'Seller ID and score are required.' });
    }

    // Find the user being rated
    const user = await User.findById(sellerId);

    if (!user) {
      return res.status(404).json({ message: 'Seller not found.' });
    }

    // Add the rating to the database
    const newRating = {
      score,
      ratedAt: new Date(),
    };

    user.ratings.push(newRating);

    // Calculate the new average rating
    const totalRatings = user.ratings.length;
    const totalScore = user.ratings.reduce((acc, rating) => acc + rating.score, 0);
    user.averageRating = totalScore / totalRatings;

    await user.save();

    res.status(200).json({
      message: 'Rating submitted successfully.',
      averageRating: user.averageRating,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'An error occurred while submitting the rating.' });
  }

};


exports.getUserInformation = async (req, res) => {
  const { username } = req.params; // Extract username from route parameter

  try {
    if (!username) {
      throw new Error('Username is required');
    }

    // Find the user by username and exclude __v
    const user = await User.findOne({ username }, { __v: 0 });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Exclude password from the response
    const { password, ...userInfo } = user.toObject();
    res.status(200).json(userInfo);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};




exports.getGuestToken = async (req, res) => {
  const payload = {
    username: 'Guest', // Username
  };

  // Generate a JWT
  const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '1h' });

  res.status(200).json({
    message: 'Guest token generated successfully.',
    token,
  });
};