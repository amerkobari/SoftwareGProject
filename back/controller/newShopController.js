const NewShop = require('../models/newShopModel');

// Add a new shop
exports.addNewShop = async (req, res) => {
    try {
        const { city, shopName, description, shopAddress, email, phoneNumber } = req.body;

        // Process uploaded logo
        const logo = req.file
            ? {
                data: req.file.buffer,         // Binary data for the image
                contentType: req.file.mimetype // Image MIME type
            }
            : null;

        // Create a new shop
        const newShop = new NewShop({
            city,
            shopName,
            description,
            shopAddress,
            email,
            phoneNumber,
            logo,
        });

        // Save to the database
        const savedShop = await newShop.save();

        res.status(201).json({
            message: 'Shop added successfully!',
            shop: savedShop,
        });
    } catch (error) {
        res.status(500).json({ message: 'Failed to add shop', error: error.message });
    }

    console.log('Body:', req.body);
    console.log('File:', req.file);

};


exports.getAllShops = async (req, res) => {
    try {
        const shops = await NewShop.find().sort({ createdAt: -1 });
        res.json(shops);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getShopById = async (req, res) => {
    try {
        const shop = await NewShop.findById(req.params.id);
        if (!shop) {
            return res.status(404).json({ message: 'Shop not found' });
        }
        res.json(shop);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

//get shop by name
exports.getShopByName = async (req, res) => {
    try {
        const shop = await NewShop.findOne({ shopName: req.params.shopName });
        if (!shop) {
            return res.status(404).json({ message: 'Shop not found' });
        }
        res.json(shop);
    }
    catch (err) {
        res.status(500).json({ error: err.message });
    }
}
