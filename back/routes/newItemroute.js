const express = require('express');
const router = express.Router();
const multer = require('multer');
const itemController = require('../controller/newItemController');

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
router.post('/add-item', upload.array('images', 5), itemController.addItem);
router.get('/get-items', itemController.getAllItems);
router.get('/get-item/:id', itemController.getItemById);
router.put('/update-item/:id', itemController.updateItem);
router.delete('/delete-item/:id', itemController.deleteItem);


module.exports = router;
