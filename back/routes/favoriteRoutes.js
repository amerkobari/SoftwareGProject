const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const favController = require('../controller/favoriteController');

// Add to favorites
router.post('/add', favController.addToFavorites);

// Get user's favorites
router.get('/', favController.getFavorites);

module.exports = router;
