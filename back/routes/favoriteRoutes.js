const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const favController = require('../controller/favoriteController');

// Add to favorites
router.post('/addToFavorites', favController.addToFavorites);

// Get user's favorites
router.get('/getFavorites', favController.getFavorites);

router.post('/removeFavorite', favController.removeFavorite)

module.exports = router;
