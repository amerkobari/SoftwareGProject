const express = require('express');
const router = express.Router();
const authController = require('../controller/login.controller');

router.post('/register', authController.register);
router.post('/login', authController.login);

module.exports = router;
