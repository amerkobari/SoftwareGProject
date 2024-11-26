const express = require('express');
const router = express.Router();
const multer = require('multer');
const itemController = require('../controller/newItemController');
const verifyToken = require('../middleware/authMiddleware'); // Import middleware to verify token
const { route } = require('./newItemroute');

// Multer setup for image uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/'); // Directory to store uploaded files
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + '-' + file.originalname); // Unique filename
    },
});

const upload = multer({ storage });

// Add a new item
router.post('/add-item',verifyToken,  upload.array('images', 5), itemController.addItem);
router.get('/get-items', itemController.getAllItems);
router.get('/get-item/:id', itemController.getItemById);
router.get('/get-items-by-user/:userId', itemController.getItemsByUser);
router.get('/get-items-by-category/:category', itemController.getItemsByCategory);
router.get('/get-items-by-title/:title', itemController.getItemsByTitle);
router.get('/get-items-by-price/:price', itemController.getItemsByPriceRange);
router.get('/get-items-by-condition/:condition', itemController.getItemsByCondition);
router.get('/get-items-by-date/:date', itemController.getItemsByDate);
router.put('/update-item/:id', verifyToken, itemController.updateItem);
router.delete('/delete-item/:id', verifyToken, itemController.deleteItem);

module.exports = router;
