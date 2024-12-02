const Item = require('../models/newItemModel');

// Add a new item
exports.addItem = async (req, res) => {
    try {
        const { title, description, price, category, condition, location } = req.body;

        // Get userId and username from middleware
        const userId = req.userId;
        const username = req.username;

        // Process uploaded images
        const images = req.files
            ? req.files.map(file => ({
                data: file.buffer,         // Binary data for the image
                contentType: file.mimetype // Image MIME type
            }))
            : []; // Default to an empty array if no images are uploaded

        // Create a new item
        const newItem = new Item({
            userId,
            username,
            title,
            description,
            images,
            price,
            category,
            condition,
            location,
        });

        // Save to the database
        const savedItem = await newItem.save();

        res.status(201).json({
            message: 'Item added successfully',
            item: savedItem,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

//add item with id
exports.addItemId = async (req, res) => {

    try {
        const { title, description, price, category, condition, location} = req.body;

        const userId = req.userId;
        const username = req.username;
        // Process uploaded images
        const images = req.files
            ? req.files.map(file => ({
            data: file.buffer,         // Binary data for the image
            contentType: file.mimetype // Image MIME type
            }))
            : []; // Default to an empty array if no images are uploaded

        // Create a new item with the provided userId
        const itemData = {
            userId,
            username,
            title,
            // ShopId,
            description,
            images,
            price,
            category,
            condition,
            location,
        }

        console.log({itemData});
        
        const newItem = new Item(itemData);

        // Save to the database
        const savedItem = await newItem.save();

        res.status(201).json({
            message: 'Item added successfully',
            item: savedItem,
        });
    } catch (err) {
        res.status(500).json({"error from backend" :{error: err.message} });
    }
};


// Get all items (with images as base64)
exports.getAllItems = async (req, res) => {
    try {
        const items = await Item.find().sort({ createdAt: -1 });
        const itemsWithImages = items.map(item => ({
            ...item.toObject(),
            images: item.images.map(image => ({
                data: image.data.toString('base64'),
                contentType: image.contentType,
            })),
        }));
        res.json(itemsWithImages);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get a single item by ID (with images as base64)
exports.getItemById = async (req, res) => {
    try {
        const item = await Item.findById(req.params.id);
        if (!item) {
            return res.status(404).json({ message: 'Item not found' });
        }

        const formattedItem = {
            ...item.toObject(),
            imageUrls: item.images?.map(image => {
                if (image?.data) {
                    return `data:${image.contentType};base64,${image.data.toString('base64')}`;
                }
                return null;
            }) || [],
        };
        
        res.json(formattedItem);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};


// Update an item by ID
exports.updateItem = async (req, res) => {
    try {
        const { title, description, price, category, condition, location } = req.body;
        const item = await Item.findById(req.params.id);
        if (!item) {
            return res.status(404).json({ message: 'Item not found' });
        }
        item.title = title;
        item.description = description;
        item.price = price;
        item.category = category;
        item.condition = condition;
        item.location = location;

        // Handle uploaded files (if images are uploaded)
        if (req.files) {
            item.images = req.files.map(file => file.path);
        }

        const updatedItem = await item.save();

        res.json({
            message: 'Item updated successfully',
            item: updatedItem,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Delete an item by ID
exports.deleteItem = async (req, res) => {
    try {
        const item = await Item.findById(req.params.id);
        if (!item) {
            return res.status(404).json({ message: 'Item not found' });
        }
        await item.remove();
        res.json({ message: 'Item deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get items by user ID
exports.getItemsByUser = async (req, res) => {
    try {
        const items = await Item.find({ userId: req.params.userId });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get items by category
exports.getItemsByCategory = async (req, res) => {
    try {
        const items = await Item.find({ category: req.params.category });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get items by title
exports.getItemsByTitle = async (req, res) => {
    try {
        const items = await Item.find({ title: { $regex: req.params.title, $options: 'i' } });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get items by price range
exports.getItemsByPriceRange = async (req, res) => {
    try {
        const { minPrice, maxPrice } = req.query;
        const items = await Item.find({
            price: { $gte: minPrice, $lte: maxPrice }
        });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get items by condition
exports.getItemsByCondition = async (req, res) => {
    try {
        const items = await Item.find({ condition: req.params.condition });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get items by date
exports.getItemsByDate = async (req, res) => {
    try {
        const items = await Item.find({ createdAt: { $gte: new Date(req.params.date) } });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
