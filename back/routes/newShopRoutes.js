const express = require('express');
const router = express.Router();
const multer = require('multer');
const newShopController = require('../controller/newShopController');


// Configure Multer for in-memory storage
const storage = multer.memoryStorage(); // Use memory storage for binary processing
const upload = multer({ storage });


// POST /api/shops/add
// router.post('/add', upload.single('logo'), newaddNewShop);
router.post('/add-shop', upload.single('logo'), newShopController.addNewShop);
router.get('/get-allshops', newShopController.getAllShops);
router.get('/get-shop/:id', newShopController.getShopById);
router.get('/get-shop/name', newShopController.getShopByName);

module.exports = router;
