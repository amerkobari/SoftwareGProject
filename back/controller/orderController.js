const Order = require('../models/orderModel'); // Import the Order model

const { sendOrderStatusUpdateMail } = require('./resetcode'); // Adjust path as needed

// Add a new order
exports.addOrder = async (req, res) => {
  const { orderDetails } = req.body;
  const { firstName, lastName, email, items, total, deliveryAddress, city, phoneNumber } = orderDetails;

  if (!firstName || !lastName || !email || !items || !total || !deliveryAddress || !city || !phoneNumber) {
    return res.status(400).json({ success: false, message: 'All fields are required' });
  }

  // Create a new order object with default status as 'Pending'
  const newOrder = new Order({
    firstName,
    lastName,
    email,
    items,
    total,
    deliveryAddress,
    city,
    phoneNumber,
    status: 'Pending', // Default status
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

// Check if this is the user's first order
exports.checkFirstOrder = async (req, res) => {
  const email = req.params.email; // Retrieve the email from the route parameter
  try {
    const userOrders = await Order.find({ email: email });

    const isFirstOrder = userOrders.length === 0;
    
    res.json({ success: true, isFirstOrder });
  } catch (error) {
    console.log('Error checking first order:', error);
    res.status(500).json({ success: false, message: 'Server error', error });
  }
};

// Get all orders by email
exports.getOrdersByEmail = async (req, res) => {
  const email = req.params.email;

  try {
    const orders = await Order.find({ email: email });

    if (orders.length === 0) {
      return res.status(404).json({ success: false, message: 'No orders found for this email' });
    }

    res.status(200).json({ success: true, orders });
  } catch (error) {
    console.error('Error fetching orders by email:', error);
    res.status(500).json({ success: false, message: 'Error fetching orders', error });
  }
};

// Get details of a specific order
exports.getOrderDetails = async (req, res) => {
  const { orderId } = req.params;

  try {
    const order = await Order.findById(orderId);

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    res.status(200).json({
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
        status: order.status, // Include status in the response
      },
    });
  } catch (error) {
    console.error('Error fetching order details:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Update the status of an order (Admin action)
exports.updateOrderStatus = async (req, res) => {
  const { orderId } = req.params;
  const { status } = req.body;

  if (!['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].includes(status)) {
    return res.status(400).json({ success: false, message: 'Invalid status value' });
  }

  try {
    // Find and update the order status
    const updatedOrder = await Order.findByIdAndUpdate(
      orderId,
      { status },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Use the imported function to send email
    const emailSent = await sendOrderStatusUpdateMail(
      updatedOrder.email,
      updatedOrder._id,
      status
    );

    res.status(200).json({
      success: true,
      message: `Order status updated to ${status} successfully. Email sent: ${emailSent ? 'Yes' : 'No'}`,
      order: updatedOrder,
    });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ success: false, message: 'Error updating order status', error });
  }
};



exports.getAllOrders = async (req, res) => {
  try {
      // Fetch all orders
      const orders = await Order.find().sort({ createdAt: -1 });

      res.status(200).json(orders);
  } catch (error) {
      console.error('Error fetching orders:', error);
      res.status(500).json({ error: 'An error occurred while fetching orders.' });
  }
}


exports.getOrderStatistics = async (req, res) => {
  try {
    const totalOrders = await Order.countDocuments();
    const completedOrders = await Order.countDocuments({ status: 'Delivered' });
    const pendingOrders = await Order.countDocuments({ status: 'Pending' });

    const orders = await Order.find({ status: 'Delivered' });

    let totalRevenue = 0;
    let totalDeliveryFees = 0;
    let totalChargeFees = 0;

    orders.forEach(order => {
      const itemPricesSum = order.items.reduce((sum, item) => sum + item.price, 0); // Sum of item prices
      const deliveryFee = Math.abs(order.total - itemPricesSum); // Calculate delivery fee with absolute value
      totalDeliveryFees += deliveryFee;

      const chargeFees = order.items.reduce((sum, item) => {
        let feePercentage;
        const price = item.price;

        if (price >= 1000) {
          feePercentage = 8.0;
        } else if (price >= 800) {
          feePercentage = 7.0;
        } else if (price >= 300) {
          feePercentage = 5.0;
        } else {
          feePercentage = 3.0;
        }

        const chargeFee = (price * feePercentage) / 100;
        return sum + chargeFee;
      }, 0);

      totalChargeFees += chargeFees;
      totalRevenue += order.total;
    });

    res.json({
      totalOrders,
      completedOrders,
      pendingOrders,
      totalRevenue,
      totalDeliveryFees,
      totalChargeFees,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getOrderStatistics2 = async (req, res) => {
  try {
    const orders = await Order.find({ status: 'Delivered' });

    let totalOrders = orders.length;
    let completedOrders = await Order.countDocuments({ status: 'Delivered' });
    let pendingOrders = await Order.countDocuments({ status: 'Pending' });

    let totalRevenue = 0;
    let deliveryFeeData = {};
    let chargeFeeData = [];
    let monthlyRevenue = {};

    orders.forEach(order => {
      const itemPricesSum = order.items.reduce((sum, item) => sum + item.price, 0);
      const deliveryFee = order.total - itemPricesSum;
      totalRevenue += order.total;

      // Aggregate delivery fee distribution
      deliveryFeeData[deliveryFee] = (deliveryFeeData[deliveryFee] || 0) + 1;

      // Calculate charge fees per order
      let chargeFees = order.items.reduce((sum, item) => {
        let feePercentage;
        if (item.price >= 1000) feePercentage = 8.0;
        else if (item.price >= 800) feePercentage = 7.0;
        else if (item.price >= 300) feePercentage = 5.0;
        else feePercentage = 3.0;
        return sum + (item.price * feePercentage) / 100;
      }, 0);
      chargeFeeData.push(chargeFees);

      // Revenue by month
      const month = new Date(order.createdAt).getMonth(); // 0 = Jan, 11 = Dec
      monthlyRevenue[month] = (monthlyRevenue[month] || 0) + order.total;
    });

    res.json({
      totalOrders,
      completedOrders,
      pendingOrders,
      totalRevenue,
      deliveryFeeData,
      chargeFeeData,
      monthlyRevenue,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getOrderStatistics3 = async (req, res) => {
  try {
    const orders = await Order.find({ status: 'Delivered' });

    let totalRevenue = 0;
    let totalDeliveryFees = 0;
    let totalChargeFees = 0;

    orders.forEach(order => {
      const itemPricesSum = order.items.reduce((sum, item) => sum + item.price, 0);
      const deliveryFee = order.total - itemPricesSum;
      totalDeliveryFees += deliveryFee;
      totalRevenue += order.total;

      // Calculate charge fees per order
      const chargeFees = order.items.reduce((sum, item) => {
        let feePercentage;
        if (item.price >= 1000) feePercentage = 8.0;
        else if (item.price >= 800) feePercentage = 7.0;
        else if (item.price >= 300) feePercentage = 5.0;
        else feePercentage = 3.0;
        return sum + (item.price * feePercentage) / 100;
      }, 0);
      totalChargeFees += chargeFees;
    });

    res.json({
      totalRevenue,
      totalDeliveryFees,
      totalChargeFees,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
