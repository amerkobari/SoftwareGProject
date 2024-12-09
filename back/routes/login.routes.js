const express = require('express');
const router = express.Router();
const authController = require('../controller/login.controller');

router.post('/register', authController.register);
router.post('/login', authController.login);

router.get('/get-user-information/:username', authController.getUserInformation);

module.exports = router;
