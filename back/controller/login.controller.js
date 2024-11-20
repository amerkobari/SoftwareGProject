const User = require('../models/login.model.js');
const jwt = require('jsonwebtoken');

// Register new user
exports.register = async (req, res) => {
  const { username, email, phoneNumber, birthdate, password, confirmPassword } = req.body;

  // Validate fields
  if (!username || !email || !phoneNumber || !birthdate || !password || !confirmPassword) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  if (password !== confirmPassword) {
    return res.status(400).json({ error: 'Passwords do not match' });
  }

  try {
    // Create new user
    const user = new User({
      username,
      email,
      phoneNumber,
      birthdate,
      password,
    });

    await user.save();
    res.status(201).json({ message: 'User registered successfully!' });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ error: 'Email already exists' });
    }
    res.status(500).json({ error: 'Server error' });
  }
};

// Login user
exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }
    const token = jwt.sign({ id: user._id }, 'your_jwt_secret', { expiresIn: '1h' });
    res.status(200).json({ message: 'Login successful', token });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};
