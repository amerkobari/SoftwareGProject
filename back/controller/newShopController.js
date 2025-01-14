const NewShop = require('../models/newShopModel');
const { sendShopConfirmationEmail } = require('./resetcode'); // Adjust path as needed
// Add a new shop
exports.addNewShop = async (req, res) => {
    try {
        const { city, shopName, description, shopAddress, email, phoneNumber } = req.body;

        // Process uploaded logo
        let logo = null;
        if (req.file) {
            try {
                logo = {
                    data: req.file.buffer,         // Binary data for the image
                    contentType: req.file.mimetype // Image MIME type
                };
            } catch (err) {
                console.error("Error processing uploaded logo:", err.message);
            }
        }

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
        console.error("Error adding new shop:", error.message);
        res.status(500).json({ message: 'Failed to add shop', error: error.message });
    }

    console.log('Body:', req.body);
    console.log('File:', req.file);
};

// Get all shops
exports.getAllShops = async (req, res) => {
    try {
        // Fetch only confirmed shops
        const shops = await NewShop.find({ isConfirmed: true }).sort({ createdAt: -1 });

        // Format the shops with logo URLs
        const formattedShops = shops.map(shop => {
            const logo = shop.logo;
            const formattedLogo = logo?.data
                ? `data:${logo.contentType};base64,${logo.data.toString('base64')}`
                : null;

            return {
                ...shop.toObject(),
                logoUrl: formattedLogo, // Add the processed logo as a new property
            };
        });

        res.json(formattedShops);
    } catch (err) {
        console.error("Error fetching confirmed shops:", err.message);
        res.status(500).json({ error: err.message });
    }
};
exports.getShopId = async (req, res) => {
    try {
        const email = req.email; // Middleware populates req.email
        

        // Fetch the shop using the email
        const shop = await NewShop.findOne({ email });
       

        if (!shop) {
            return res.status(404).json({ error: 'Shop not found' });
        }

       
        
        // Return the shop ID as a plain string
        res.json({ shopId: shop._id.toString() });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
};


// Get shop by ID
exports.getShopById = async (req, res) => {
    try {
        const shop = await NewShop.findById(req.params.id);
        if (!shop) {
            return res.status(404).json({ message: 'Shop not found' });
        }

        // Format the shop data similarly to the item
        const formattedShop = {
            ...shop.toObject(), // Convert the Mongoose document to a plain object
            logoUrl: shop.logo?.data
                ? `data:${shop.logo.contentType};base64,${shop.logo.data.toString('base64')}`
                : null, // Format the logo into a Base64 string
        };

        res.json(formattedShop);
    } catch (err) {
        console.error(`Error fetching shop by ID (${req.params.id}):`, err.message);
        res.status(500).json({ error: err.message });
    }
};


// Get shop by name
exports.getShopByName = async (req, res) => {
    try {
        const shop = await NewShop.findOne({ shopName: req.params.shopName });
        if (!shop) {
            return res.status(404).json({ message: 'Shop not found' });
        }
        res.json(shop);
    } catch (err) {
        console.error(`Error fetching shop by name (${req.params.shopName}):`, err.message);
        res.status(500).json({ error: err.message });
    }
};
exports.confirmShop = async (req, res) => {
    const { shopId } = req.params;

    try {
        // Find and update the shop
        const updatedShop = await NewShop.findByIdAndUpdate(
            shopId,
            { isConfirmed: true },
            { new: true }
        );

        if (!updatedShop) {
            return res.status(404).json({ success: false, message: 'Shop not found' });
        }

        // Send confirmation email
        const emailSent = await sendShopConfirmationEmail(
            updatedShop.email,
            updatedShop.shopName
        );

        res.status(200).json({
            success: true,
            message: `Shop confirmed successfully. Email sent: ${emailSent ? 'Yes' : 'No'}`,
            shop: updatedShop,
        });
    } catch (error) {
        console.error('Error confirming shop:', error);
        res.status(500).json({ success: false, message: 'Server error', error });
    }
};

// Get all unconfirmed shops
exports.getUnconfirmedShops = async (req, res) => {
    try {
        const unconfirmedShops = await NewShop.find({ isConfirmed: false }).sort({ createdAt: -1 });

        const formattedShops = unconfirmedShops.map(shop => {
            const logo = shop.logo;
            const formattedLogo = logo?.data
                ? `data:${logo.contentType};base64,${logo.data.toString('base64')}`
                : null;

            return {
                ...shop.toObject(),
                logoUrl: formattedLogo, // Add the processed logo as a new property
            };
        });

        res.json(formattedShops);
    } catch (err) {
        console.error("Error fetching unconfirmed shops:", err.message);
        res.status(500).json({ error: err.message });
    }
};
exports.deleteShopById = async (req, res) => {
    try {
        const { id } = req.params;

        // Find and delete the shop by ID
        const deletedShop = await NewShop.findByIdAndDelete(id);

        if (!deletedShop) {
            return res.status(404).json({ success: false, message: 'Shop not found' });
        }

        res.status(200).json({
            success: true,
            message: 'Shop deleted successfully',
            shop: deletedShop
        });
    } catch (error) {
        console.error('Error deleting shop:', error.message);
        res.status(500).json({ success: false, message: 'Failed to delete shop', error: error.message });
    }
};

exports.getShopStatistics = async (req, res) => {
    try {
      const totalShops = await NewShop.countDocuments();
      const confirmedShops = await NewShop.countDocuments({ isConfirmed: true });
      const unconfirmedShops = await NewShop.countDocuments({ isConfirmed: false });
      res.json({ totalShops, confirmedShops, unconfirmedShops });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };