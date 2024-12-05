// routes/distanceRoutes.js

const express = require('express');
const router = express.Router();
const distanceController = require('../controller/distanceController');

router.post('/get-distance', distanceController.getDistance);

module.exports = router;
