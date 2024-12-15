const express = require('express');
const router = express.Router();
const authController = require('../controller/login.controller');
const verifyToken = require('../middleware/authMiddleware');

router.post('/register', authController.register);
router.post('/login', authController.login);

router.get('/get-user-information/:username', authController.getUserInformation);
router.get('/get-guest-token', authController.getGuestToken);
router.post('/rate',  authController.rateUser);
router.put('/updateAverageRating', authController.updateAverageRating);
module.exports = router;
