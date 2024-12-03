const mongoose = require('mongoose');
const { getShopId } = require('../controller/newShopController');

const imageSchema = new mongoose.Schema({
    data: Buffer, // Store image data in binary format
    contentType: String, // MIME type of the image
});

const itemSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, required: true },
    username: { type: String, required: true },
    title: { type: String, required: true },
    description: { type: String },
    images: [imageSchema], // Store multiple images
    price: { type: Number, required: true },
    category: { type: String, required: true },
    condition: { type: String },
    location: { type: String },
    createdAt: { type: Date, default: Date.now },
    shopId: { type: mongoose.Schema.Types.ObjectId, required: false },
    
});

module.exports = mongoose.model('Item', itemSchema);
