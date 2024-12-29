const Item = require('../models/newItemModel');
const Shop = require('../models/newShopModel'); 

// Add a new item
exports.addItem = async (req, res) => {
    try {
        const { title, description, price, category, condition, location, shopId } = req.body;

        // Get userId and username from middleware
        const userId = req.userId;
        const username = req.username;

        // Process uploaded images
        const images = req.files
            ? req.files.map(file => ({
                data: file.buffer,
                contentType: file.mimetype
            }))
            : [];

        // Validate shopId if provided
        let validShopId;
        if (shopId) {
            validShopId = await Shop.findById(shopId);
            if (!validShopId) {
                return res.status(400).json({ error: 'Invalid shop ID' });
            }
        }

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
            shopId: validShopId ? shopId : undefined, // Only include shopId if valid
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
        const items = await Item.find({ sold: false }).sort({ createdAt: -1 });
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
        const item = await Item.findOne({ _id: req.params.id, sold: false });
        if (!item) {
            return res.status(404).json({ message: 'Item not found or already sold' });
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


exports.getShopItems = async (req, res) => {
    try {
        const items = await Item.find({ shopId: req.params.shopId, sold: false });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};



// Update an item by ID
exports.updateItem = async (req, res) => {
    console.log("were inside the update item");
    try {
        console.log("were inside the update item");
        console.log('Request Body:', req.body);
        console.log('Request Files:', req.files);

        

        const { title, description, price, condition, location } = req.body;
        const item = await Item.findById(req.params.id);
        if (!item) {
            return res.status(404).json({ error: 'Item not found' });
        }

        // Update fields
        item.title = title;
        item.description = description;
        item.price = price;
        item.condition = condition;
        item.location = location;

        // Handle images
        if (req.files) {
            item.images = req.files.map(file => ({
            data: file.buffer,
            contentType: file.mimetype,
            }));
        }

        const updatedItem = await item.save();
        res.json({ message: 'Item updated successfully', item: updatedItem });
    } catch (err) {
        console.error('Error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};


// Delete an item by ID
exports.deleteItem = async (req, res) => {
    try {
        const item = await Item.findById(req.params.id);
        if (!item) {
            return res.status(404).json({ message: 'Item not found' });
        }

        // Use deleteOne method
        await Item.deleteOne({ _id: req.params.id });
        res.json({ message: 'Item deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};


// Get items by username
exports.getItemsByUsername = async (req, res) => {
    try {
        const items = await Item.find({ username: req.params.username, sold: false });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};


// Get items by category
exports.getItemsByCategory = async (req, res) => {
    try {
        const items = await Item.find({ category: req.params.category, sold: false });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};


// Get items by title
exports.getItemsByTitle = async (req, res) => {
    try {
        const items = await Item.find({
            title: { $regex: req.params.title, $options: 'i' },
            sold: false,
        });
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
            price: { $gte: minPrice, $lte: maxPrice },
            sold: false,
        });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};


// Get items by condition
exports.getItemsByCondition = async (req, res) => {
    try {
        const items = await Item.find({ condition: req.params.condition, sold: false });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};


// Get items by date
exports.getItemsByDate = async (req, res) => {
    try {
        const items = await Item.find({
            createdAt: { $gte: new Date(req.params.date) },
            sold: false,
        });
        res.json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.updatesoldItem = async (req, res) => {
    try {
        const item = await Item.findById(req.params.id);
        if (!item) {
            return res.status(404).json({ message: 'Item not found' });
        }

        item.sold = true;
        const updatedItem = await item.save();
        res.json({ message: 'Item updated successfully', item: updatedItem });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Controller: Get all sold items
exports.getItemsSold = async (req, res) => {
    try {
      const items = await Item.find({ sold: true });
      
      // Ensure that if no items are sold, an empty array is returned
      if (!items || items.length === 0) {
        return res.status(200).json([]);
      }
  
      res.json(items);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  // Controller: Get the number of items sold for a specific user (using route parameter)
  exports.getItemsSoldCount = async (req, res) => {
    const { username } = req.params;
  
    try {
      if (!username) {
        return res.status(400).json({ error: 'Username is required' });
      }
  
      // Count the number of sold items for the specified username
      const soldCount = await Item.countDocuments({ username, sold: true });
  
      res.status(200).json({
        username,
        soldCount,
      });
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  };
  
  // Controller: Calculate the balance (sum of sold item prices) for a specific user (using route parameter)
//   exports.getUserBalance = async (req, res) => {
//     const { username } = req.params;
  
//     try {
//       if (!username) {
//         return res.status(400).json({ error: 'Username is required' });
//       }
  
//       // Aggregate the balance for sold items belonging to the specified username
//       const balanceResult = await Item.aggregate([
//         { $match: { username, sold: true } }, // Filter by username and sold items
//         {
//           $group: {
//             _id: null, // We don’t need to group by any field
//             totalBalance: { $sum: '$price' }, // Sum prices of sold items
//           },
//         },
//       ]);
  
//       const totalBalance = balanceResult.length > 0 ? balanceResult[0].totalBalance : 0;
  
//       res.status(200).json({
//         username,
//         balance: totalBalance,
//       });
//     } catch (err) {
//       res.status(400).json({ error: err.message });
//     }
//   };
  
exports.getUserBalance = async (req, res) => {
    const { username } = req.params;

    try {
        if (!username) {
            return res.status(400).json({ error: 'Username is required' });
        }

        // Aggregate the balance for sold items belonging to the specified username
        const balanceResult = await Item.aggregate([
            { $match: { username, sold: true } }, // Filter by username and sold items
            {
                $addFields: {
                    fee: {
                        $switch: {
                            branches: [
                                { case: { $gte: ['$price', 1000] }, then: { $multiply: ['$price', 0.08] } },
                                { case: { $gte: ['$price', 800] }, then: { $multiply: ['$price', 0.07] } },
                                { case: { $gte: ['$price', 300] }, then: { $multiply: ['$price', 0.05] } }
                            ],
                            default: { $multiply: ['$price', 0.03] } // Default fee for prices below 300
                        }
                    }
                }
            },
            {
                $group: {
                    _id: null, // No grouping field needed
                    totalBalance: {
                        $sum: {
                            $subtract: ['$price', '$fee'] // Subtract fee from each price
                        }
                    }
                }
            }
        ]);

        const totalBalance = balanceResult.length > 0 ? balanceResult[0].totalBalance : 0;

        res.status(200).json({
            username,
            balance: totalBalance,
        });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};


exports.searchItemsByTitle = async (req, res) => {
    const { title } = req.query;
  
    if (!title) {
      return res.status(400).json({ error: 'Title query parameter is required.' });
    }
  
    try {
      const regexQuery = { title: { $regex: title, $options: 'i' } }; // Case-insensitive search
      const items = await Item.find(regexQuery).select('title description price images category location');
      res.status(200).json(items);
    } catch (error) {
      console.error('Error searching items:', error);
      res.status(500).json({ error: 'An error occurred while searching for items.' });
    }
  };