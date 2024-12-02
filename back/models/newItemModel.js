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
    ShopId: { type: mongoose.Schema.Types.ObjectId, required: false },
    
});

// const itemSchema1 = new mongoose.Schema({
//     userId: { type: mongoose.Schema.Types.ObjectId, required: true },
//     username: { type: String, required: true },
//     title: { type: String, required: true },
//     description: { type: String },
//     images: [imageSchema], // Store multiple images
//     price: { type: Number, required: true },
//     category: { type: String, required: true },
//     condition: { type: String },
//     location: { type: String },
//     createdAt: { type: Date, default: Date.now },
//     // ShopId: { type: mongoose.Schema.Types.ObjectId, required: true },
// });

module.exports = mongoose.model('Item', itemSchema);
