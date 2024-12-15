const Favorite = require('../models/favoriteModel');
const User = require('../models/user'); // Ensure you have access to the User model
const Item = require('../models/newItemModel'); // Optional: If you need to populate item details

// Add item to favorites
exports.addToFavorites = async (req, res) => {
  try {
    const { username, itemId } = req.body; // Expect username and itemId

    if (!username || !itemId) {
      return res.status(400).json({ message: 'Username and Item ID are required.' });
    }

    // Find the user by username
    const user = await User.findOne({ username });

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // Find or create the user's favorite list
    let favorite = await Favorite.findOne({ userId: user._id });

    if (!favorite) {
      // If no favorite document exists, create one
      favorite = new Favorite({ userId: user._id, items: [] });
    }

    // Check if the item is already in the favorites
    const alreadyFavorited = favorite.items.some((item) => item.itemId.toString() === itemId);

    if (alreadyFavorited) {
      return res.status(400).json({ message: 'Item is already in favorites.' });
    }

    // Add item to favorites
    favorite.items.push({ itemId });
    await favorite.save();

    res.status(200).json({ message: 'Item added to favorites.', favorites: favorite });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// Get user's favorites
exports.getFavorites = async (req, res) => {
  try {
    const { username } = req.query; // Get username from query parameters

    if (!username) {
      return res.status(400).json({ message: 'Username is required.' });
    }

    // Find the user by username
    const user = await User.findOne({ username });

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // Find the user's favorite list
    const favorites = await Favorite.findOne({ userId: user._id }).populate('items.itemId'); // Optionally populate item details
    res.status(200).json(favorites || { items: [] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// Remove item from favorites
exports.removeFavorite = async (req, res) => {
  try {
    const { username, itemId } = req.body; // Expect username and itemId

    if (!username || !itemId) {
      return res.status(400).json({ message: 'Username and Item ID are required.' });
    }

    // Find the user by username
    const user = await User.findOne({ username });

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // Find the user's favorite list
    const favorite = await Favorite.findOne({ userId: user._id });

    if (!favorite) {
      return res.status(404).json({ message: 'Favorites list not found.' });
    }

    // Check if the item exists in the user's favorites
    const itemIndex = favorite.items.findIndex((item) => item.itemId.toString() === itemId);

    if (itemIndex === -1) {
      return res.status(404).json({ message: 'Item not found in favorites.' });
    }

    // Remove the item from favorites
    favorite.items.splice(itemIndex, 1);
    await favorite.save();

    res.status(200).json({ message: 'Item removed from favorites.', favorites: favorite });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error.' });
  }
};
