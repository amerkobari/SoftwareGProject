const mongoose = require('mongoose');

const FavoriteSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'users', required: true },
  items: [
    {
      itemId: { type: mongoose.Schema.Types.ObjectId, required: true }, // Reference to item collection or identifier
      addedAt: { type: Date, default: Date.now }
    }
  ]
});

module.exports = mongoose.model('Favorite', FavoriteSchema);
