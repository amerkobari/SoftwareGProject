const express = require('express');
const router = express.Router();
// const verifyToken = require('../middleware/authMiddleware');
const cartController = require('../controller/cartController');

// Add to cart
router.post('/addtoCart', cartController.addToCart);

// Get user's cart
router.get('/getCart', cartController.getCart);

router.post('/removeCartItem', cartController.removeCartItem);


module.exports = router;
