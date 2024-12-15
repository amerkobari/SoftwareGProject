const mongoose = require('mongoose');

// Assuming you have already defined and exported the 'Item' model
const Item = require('./newItemModel.js'); 

const FavoriteSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'users', required: true },
  items: [
    {
      itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Item', required: true }, // Reference to Item model
      addedAt: { type: Date, default: Date.now },
      title: { type: String }, // Optional field to store the title
      price: { type: Number }, // Optional field to store the price
      images: [{ data: Buffer, contentType: String }], // Optional field to store images of the item
      description: { type: String }, // Optional field to store the description
    }
  ]
});

FavoriteSchema.pre('save', async function(next) {
  // Pre-save hook to populate the item details for each favorite item
  const favorite = this;

  // Loop through each item in the favorites list
  for (const item of favorite.items) {
    const itemDetails = await Item.findById(item.itemId).select('title price images description');

    // Add the item details to the favorite item
    item.title = itemDetails.title;
    item.price = itemDetails.price;
    item.images = itemDetails.images;
    item.description = itemDetails.description;
  }

  next(); // Proceed with the save operation
});

module.exports = mongoose.model('Favorite', FavoriteSchema);
