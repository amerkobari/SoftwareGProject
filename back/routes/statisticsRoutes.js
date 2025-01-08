const express = require('express');
const { getUserStatistics } = require('../controller/login.controller');
const { getOrderStatistics } = require('../controller/orderController');
const { getOrderStatistics2 } = require('../controller/orderController');
const { getOrderStatistics3 } = require('../controller/orderController');
const { getShopStatistics } = require('../controller/newShopController');
const { getItemStatistics } = require('../controller/newItemController');


const router = express.Router();

router.get('/users-stat', getUserStatistics);
router.get('/orders-stat', getOrderStatistics);
router.get('/orders-stat2', getOrderStatistics2);
router.get('/orders-stat3', getOrderStatistics3);
router.get('/shops-stat', getShopStatistics);
router.get('/items-stat', getItemStatistics);

module.exports = router;
