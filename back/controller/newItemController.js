const Item = require('../models/newItemModel');

// Add a new item
exports.addItem = async (req, res) => {
    try {
        const { userId, title, description, price, category, condition, location } = req.body;

        // Handle uploaded files (if images are uploaded)
        const images = req.files ? req.files.map(file => file.path) : [];

        // Create a new item document
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

        // Save the item to the database
        const savedItem = await newItem.save();

        res.status(201).json({
            message: 'Item added successfully',
            item: savedItem,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get all items
exports.getAllItems = async (req, res) => {
    try {
        const items = await Item.find().sort({ createdAt: -1 });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get a single item by ID
exports.getItemById = async (req, res) => {
    try {
        const item = await Item.findById(req.params.id);
        if (!item) {
            return res.status(404).json({ message: 'Item not found' });
        }
        res.json(item);
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
}
