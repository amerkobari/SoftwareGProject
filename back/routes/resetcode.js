// routes/authRoutes.js
const express = require('express');
const authController = require('../controller/resetcode');

const router = express.Router();

// Endpoint to send reset code
router.post('/send-reset-code', authController.sendResetCode);

// Endpoint to reset password
router.post('/reset-password', authController.resetPassword);

module.exports = router;
