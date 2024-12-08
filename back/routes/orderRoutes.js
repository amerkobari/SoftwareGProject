const express = require('express');
const router = express.Router();
const orderController = require('../controller/orderController'); // Import the controller

// Route to create a new order
router.post('/add-new-order', orderController.addOrder);
router.get('/check-first-order/:email', orderController.checkFirstOrder);
module.exports = router;
