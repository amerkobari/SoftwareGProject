const mongoose = require('mongoose');

// const logoSchema = new mongoose.Schema({
//     data: Buffer,        // Binary data for the logo
//     contentType: String, // MIME type of the logo
// });

const newShopSchema = new mongoose.Schema({
    city: { type: String, required: true },
    shopName: { type: String, required: true },
    description: { type: String },
    shopAddress: { type: String, required: true },
    email: { type: String, required: true },
    phoneNumber: { type: String, required: true },
    logo: {
        data: Buffer,        // Binary data for the logo
        contentType: String, // MIME type of the logo
    },
}, { timestamps: true });

module.exports = mongoose.model('NewShop', newShopSchema);