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

exports.getOrdersByEmail = async (req, res) => {
  const email = req.params.email; // Get the email from the request parameter

  try {
    // Find all orders by the email
    const orders = await Order.find({ email: email });

    // Check if any orders were found
    if (orders.length === 0) {
      return res.status(404).json({ success: false, message: 'No orders found for this email' });
    }

    // Respond with the orders
    res.status(200).json({
      success: true,
      orders: orders
    });
  } catch (error) {
    // Handle any errors
    console.error('Error fetching orders by email:', error);
    res.status(500).json({ success: false, message: 'Error fetching orders', error });
  }
};


exports.getOrderDetails = async (req, res) => {
  const { orderId } = req.params; // Retrieve the orderId from the route parameter

  try {
    // Find the order by orderId
    const order = await Order.findById(orderId);

    // If order is not found
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Respond with the order details
    return res.status(200).json({
      success: true,
      order: {
        _id: order._id,
        firstName: order.firstName,
        lastName: order.lastName,
        email: order.email,
        items: order.items,
        total: order.total,
        deliveryAddress: order.deliveryAddress,
        city: order.city,
        phoneNumber: order.phoneNumber,
        createdAt: order.createdAt,
      },
    });
  } catch (error) {
    console.error('Error fetching order details:', error);
    return res.status(500).json({ message: 'Server error', error: error.message });
  }
};