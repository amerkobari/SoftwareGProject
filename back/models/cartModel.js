const mongoose = require('mongoose');

// Assuming you have already defined and exported the 'Item' model
const Item = require('./newItemModel.js'); 

const CartSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'users', required: true },
  items: [
    {
      itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Item', required: true }, // Reference to Item model
      addedAt: { type: Date, default: Date.now },
      title: { type: String }, // Optional field to store the title
      price: { type: Number }, // Optional field to store the price
      images: [{ data: Buffer, contentType: String }], // Optional field to store images of the item
      description: { type: String }, // Optional field to store the description
      sold: { type: Boolean, default: false }, // New field to track sold status
      location: { type: String , required: true},
    }
  ]
});

CartSchema.pre('save', async function (next) {
  const cart = this;

  // Loop through each item in the cart
  for (const item of cart.items) {
    const itemDetails = await Item.findById(item.itemId).select('title price images description location');
    
    if (itemDetails) {
      // Add the item details to the cart item
      item.title = itemDetails.title;
      item.price = itemDetails.price;
      item.images = itemDetails.images;
      item.description = itemDetails.description;
      item.location = itemDetails.location; // Populate the location field
    } else {
      throw new Error(`Item with ID ${item.itemId} not found`);
    }
  }

  next(); // Proceed with the save operation
});


module.exports = mongoose.model('Cart', CartSchema);
