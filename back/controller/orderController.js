const Order = require('../models/orderModel'); // Import the Order model

exports.addOrder = async (req, res) => {
  const { orderDetails } = req.body;
  const { firstName, lastName, email, items, total, deliveryAddress, city, phoneNumber } = orderDetails;
  // const { firstName, lastName, email, items, total, deliveryAddress, city, phoneNumber } = req.body;

  if (!firstName || !lastName || !email || !items || !total || !deliveryAddress || !city || !phoneNumber) {
    return res.status(400).json({ success: false, message: 'All fields are required' });
  }

  // Create a new order object
  const newOrder = new Order({
    firstName,
    lastName,
    email,
    items,
    total,
    deliveryAddress,
    city,
    phoneNumber
  });

  try {
    // Save the order to the database
    const savedOrder = await newOrder.save();
    
    // Respond with success
    res.status(201).json({
      success: true,
      message: 'Order placed successfully',
      order: savedOrder
    });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ success: false, message: 'Error saving order to the database' });
  }
};
