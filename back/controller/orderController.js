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

exports.checkFirstOrder = async (req, res) => {
  const email = req.params.email; // Retrieve the email from the route parameter
  console.log('Checking first order for:', email);
  try {
    // Query the database using the email field
    const userOrders = await Order.find({ email: email });

    // Determine if this is the first order
    const isFirstOrder = userOrders.length === 0;
    console.log('Is first order:', isFirstOrder);
    
    // Respond with the result
    res.json({ success: true, isFirstOrder });
  } catch (error) {
    // Handle any errors
    console.log('Error checking first order:', error);
    res.status(500).json({ success: false, message: 'Server error', error });
  }
};