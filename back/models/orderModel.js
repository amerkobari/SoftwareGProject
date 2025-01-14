const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true },
  items: [{
    name: { type: String, required: true },
    price: { type: Number, required: true },
    imageUrl: { type: [String], required: true },
    imageCid: { type: String, required: true },
    itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Item', required: true },
    category: { type: String, ref: 'Item', required: true }
  }],
  total: { type: Number, required: true },
  deliveryAddress: { type: String, required: true },
  city: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  status: { 
    type: String, 
    enum: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'], 
    default: 'Pending' 
  }
});

const Order = mongoose.model('Order', OrderSchema);

module.exports = Order;
