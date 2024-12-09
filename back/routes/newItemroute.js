const express = require('express');
const router = express.Router();
const multer = require('multer');
const itemController = require('../controller/newItemController');
const verifyToken = require('../middleware/authMiddleware'); // Import middleware to verify token

// Multer setup for image uploads (in memory)
const storage = multer.memoryStorage(); // Store images in memory
const upload = multer({ storage });

// Add a new item with images
router.post('/add-item', verifyToken, upload.array('images', 5), itemController.addItem);
router.post('/add-item-withId', verifyToken ,itemController.addItemId);
router.get('/get-items-by-shop/:shopId', itemController.getShopItems);
// Get all items
router.get('/get-items', itemController.getAllItems);

// Get a single item by ID
router.get('/get-item/:id', itemController.getItemById);

// Other routes remain the same
// router.get('/get-items-by-user/:userId', itemController.getItemsByUser);
router.get('/get-items-by-category/:category', itemController.getItemsByCategory);
router.get('/get-items-by-title/:title', itemController.getItemsByTitle);
router.get('/get-items-by-price/:price', itemController.getItemsByPriceRange);
router.get('/get-items-by-condition/:condition', itemController.getItemsByCondition);
router.get('/get-items-by-date/:date', itemController.getItemsByDate);
router.put('/update-item/:id', upload.array('images' , 5),itemController.updateItem);
router.put('/update-item-sold/:id', itemController.updatesoldItem);
router.delete('/delete-item/:id', itemController.deleteItem);

router.get('/count-items-sold/:username', itemController.getItemsSoldCount);
router.get('/items-sold/:username', itemController.getItemsSold);
router.get('/user-balance/:username', itemController.getUserBalance);

router.get('/get-items-by-user/:username', itemController.getItemsByUsername);

module.exports = router;
