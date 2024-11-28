const User = require('../models/user');
const nodemailer = require('nodemailer');
const bcrypt = require('bcrypt');

// Configure nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail', // Replace with your email provider
  auth: {
    user: 'rentitoutco@gmail.com',
    pass: 'yooghhahjavtasqr',
  },
});

// Generate random 6-digit code
function generateCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Send reset code
exports.sendResetCode = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'Email not found' });
    }

    // Generate reset code and expiration time
    const resetCode = generateCode();
    user.resetCode = resetCode;
    user.resetCodeExpires = Date.now() + 15 * 60 * 1000; // Code valid for 15 minutes
    await user.save();

    // Send the reset code via email
    await transporter.sendMail({
      from: 'rentitoutco@gmail.com',
      to: email,
      subject: 'Password Reset Code',
      text: `Your password reset code is: ${resetCode}`,
    });

    res.json({ success: true, message: 'Reset code sent successfully', resetCode });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// Reset password
exports.resetPassword = async (req, res) => {
  const { email, password, code } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'Email not found' });
    }

    // Validate reset code and its expiry
    if (user.resetCode !== code || user.resetCodeExpires < Date.now()) {
      return res.status(400).json({ success: false, message: 'Invalid or expired reset code' });
    }

    // Update password and clear reset code
    user.password = password; // Will be hashed due to the pre-save middleware
    user.resetCode = undefined;
    user.resetCodeExpires = undefined;
    await user.save();

    res.json({ success: true, message: 'Password reset successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// Send verification code
exports.sendVerificationCode = async (req, res) => {
    const { email } = req.body;
  
    try {
      // Generate a verification code
      const verificationCode = generateCode();
  
      // Send the verification code via email
      await transporter.sendMail({
        from: 'rentitoutco@gmail.com',
        to: email,
        subject: 'Verification Code',
        text: `Your verification code is: ${verificationCode}`,
      });
  
      res.status(200).json({ success: true, message: 'Verification code sent successfully.', verificationCode });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: 'Server error' });
    }
  };

  exports.sendNewShopMail = async (req, res) => {
    const { email } = req.body;
  
    try {
      // Send the verification code via email
      await transporter.sendMail({
        from: 'rentitoutco@gmail.com',
        to: email,
        subject: 'New Shop Request',
        text: `Your shop has been requested and waiting for the admin to accept it`,
  
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: 'Server error' });
    }
  }


