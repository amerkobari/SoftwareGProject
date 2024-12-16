const Cart = require('../models/cartModel');
const User = require('../models/user');
const Item = require('../models/newItemModel');

// Add item to cart
exports.addToCart = async (req, res) => {
    try {
        const { username, itemId } = req.body; // Only expect itemId and username
    
        if (!username || !itemId) {
          return res.status(400).json({ message: 'Username and itemId are required.' });
        }
    
        // Find the user by username
        const user = await User.findOne({ username });
    
        if (!user) {
          return res.status(404).json({ message: 'User not found.' });
        }
    
        // Find or create the user's cart
        let cart = await Cart.findOne({ userId: user._id });
    
        if (!cart) {
            // If cart doesn't exist, create one
            cart = new Cart({
                userId: user._id,
                items: []
            });
        }
    
        // Check if the item is already in the cart
        const existingItem = cart.items.find(item => item.itemId.toString() === itemId.toString());

        if (existingItem) {
            // Item already exists in cart, prevent adding it again
            return res.status(400).json({ message: 'Item is already in the cart.' });
        }
    
        // Add the item to the cart if it's not already there
        cart.items.push({
            itemId: itemId, // Only store itemId
            quantity: 1, // Assuming default quantity is 1, can be modified if needed
        });
    
        await cart.save();
    
        res.status(201).json({
          message: 'Item added to cart successfully.',
          cart: cart.items, // Only return items with itemIds
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'An error occurred while adding item to cart.' });
    }
};
// Add this to your backend API
exports.removeCartItem = async (req, res) => {
    try {
      const { username, itemId } = req.body;
  
      if (!username || !itemId) {
        return res.status(400).json({ message: 'Username and itemId are required.' });
      }
  
      const user = await User.findOne({ username });
      if (!user) {
        return res.status(404).json({ message: 'User not found.' });
      }
  
      const cart = await Cart.findOne({ userId: user._id });
      if (!cart) {
        return res.status(404).json({ message: 'Cart not found.' });
      }
  
      // Remove the item from the cart
      cart.items = cart.items.filter((item) => item.itemId.toString() !== itemId);
      await cart.save();
  
      res.status(200).json({ message: 'Item removed from cart.' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error.' });
    }
  };
  

// Get user's cart
exports.getCart = async (req, res) => {
  try {
      const username = req.query.username; // Get the username from the query parameter

      if (!username) {
          return res.status(400).json({ message: 'Username is required.' });
      }

      const user = await User.findOne({ username });
      if (!user) {
          return res.status(404).json({ message: 'User not found.' });
      }

      // Fetch the user's cart
      const cart = await Cart.findOne({ userId: user._id }).populate({
          path: 'items.itemId',
          select: 'title price description images category sold',
      });

      if (!cart) {
          return res.status(200).json({ items: [] });
      }

      // Filter out items where `sold: true`
      const filteredItems = cart.items.filter(item => item.itemId && !item.itemId.sold);

      // If there are changes (sold items removed), update the database
      if (filteredItems.length !== cart.items.length) {
          cart.items = filteredItems;
          await cart.save();
      }

      res.status(200).json({ items: filteredItems });
  } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error.' });
  }
};


  