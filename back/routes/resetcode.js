const express = require('express');
const authController = require('../controller/resetcode');

const router = express.Router();

// Endpoint to send reset code
router.post('/send-reset-code', authController.sendResetCode);

// Endpoint to reset password
router.post('/reset-password', authController.resetPassword);

// Endpoint to send verification code
router.post('/send-verification-code', authController.sendVerificationCode);

router.post('/send-new-shop-email', authController.sendNewShopMail);
// Endpoint to verify user during sign-up
// router.post('/verify-user', authController.verifyUser);

module.exports = router;
