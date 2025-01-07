const express = require('express');
const router = express.Router();
const orderController = require('../controller/orderController'); // Import the controller

// Route to create a new order
router.post('/add-new-order', orderController.addOrder);
router.get('/check-first-order/:email', orderController.checkFirstOrder);
router.get('/get-orders-by-email/:email', orderController.getOrdersByEmail);
router.get('/order-details/:orderId', orderController.getOrderDetails);
router.put('/orders/:orderId/status', orderController.updateOrderStatus);
router.get('/get-all-orders', orderController.getAllOrders);
module.exports = router;
