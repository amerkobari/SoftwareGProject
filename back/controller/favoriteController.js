const Favorite = require('../models/favoriteModel');

// Add item to favorites
exports.addToFavorites = async (req, res) => {
  try {
    const { itemId } = req.body;

    if (!itemId) {
      return res.status(400).json({ message: 'Item ID is required.' });
    }

    let favorite = await Favorite.findOne({ userId: req.userId });

    if (!favorite) {
      // If no favorite document exists, create one
      favorite = new Favorite({ userId: req.userId, items: [] });
    }

    // Check if item is already in favorites
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
    const favorites = await Favorite.findOne({ userId: req.userId }).populate('items.itemId');
    res.status(200).json(favorites || { items: [] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error.' });
  }
};
