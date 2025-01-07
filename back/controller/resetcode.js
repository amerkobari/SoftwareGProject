const User = require('../models/user');
const nodemailer = require('nodemailer');
const bcrypt = require('bcrypt');

// Configure nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail', // Replace with your email provider
  auth: {
    user: 'rentitoutco@gmail.com',
    pass: 'uvzrstpvbbamzfmn',
  },
});

// Generate random 6-digit code
function generateCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Send reset code
exports.sendResetCode = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'Email not found' });
    }

    // Generate reset code and expiration time
    const resetCode = generateCode();
    user.resetCode = resetCode;
    user.resetCodeExpires = Date.now() + 15 * 60 * 1000; // Code valid for 15 minutes
    await user.save();

    // Send the reset code via email
    await transporter.sendMail({
      from: 'rentitoutco@gmail.com',
      to: email,
      subject: 'Password Reset Code',
      text: `Your password reset code is: ${resetCode}`,
    });

    res.json({ success: true, message: 'Reset code sent successfully', resetCode });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// Reset password
exports.resetPassword = async (req, res) => {
  const { email, password, code } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'Email not found' });
    }

    // Validate reset code and its expiry
    if (user.resetCode !== code || user.resetCodeExpires < Date.now()) {
      return res.status(400).json({ success: false, message: 'Invalid or expired reset code' });
    }

    // Update password and clear reset code
    user.password = password; // Will be hashed due to the pre-save middleware
    user.resetCode = undefined;
    user.resetCodeExpires = undefined;
    await user.save();

    res.json({ success: true, message: 'Password reset successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// Send verification code
exports.sendVerificationCode = async (req, res) => {
    const { email } = req.body;
  
    try {
      // Generate a verification code
      const verificationCode = generateCode();
  
      // Send the verification code via email
      await transporter.sendMail({
        from: 'rentitoutco@gmail.com',
        to: email,
        subject: 'Verification Code',
        text: `Your verification code is: ${verificationCode}`,
      });
  
      res.status(200).json({ success: true, message: 'Verification code sent successfully.', verificationCode });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: 'Server error' });
    }
  };

  exports.sendNewShopMail = async (req, res) => {
    const { email } = req.body;
  
    try {
      // Send the verification code via email
      await transporter.sendMail({
        from: 'rentitoutco@gmail.com',
        to: email,
        subject: 'New Shop Request',
        text: `Your shop has been requested and waiting for the admin to accept it`,
  
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: 'Server error' });
    }
  }

  // const axios = require('axios'); // Using axios for HTTP requests
// const transporter = require('./mailer'); // Assuming transporter is set up for sending emails

exports.sendOrderMail = async (req, res) => {
  const { orderDetails } = req.body;
  
  console.log('Order Details:', JSON.stringify(orderDetails, null, 2));

  // Validate order details
  if (!orderDetails || !orderDetails.email || !orderDetails.items || !orderDetails.items.length) {
    return res.status(400).json({
      success: false,
      message: 'Invalid order details. Ensure all required fields are provided.',
    });
  }

  try {
    // Prepare email content with inline images
    const emailContent = `
      <html>
        <body>
          <h2>Hello ${orderDetails.firstName} ${orderDetails.lastName},</h2>
          <p>Your order has been placed successfully!</p>
          <h3>Order Details:</h3>
          <ul>
            ${orderDetails.items
              .map(
                (item) => `
              <li>
              <b>${item.name}</b> - ₪${item.price} <br>
                ${item.imageUrl.map((image, imgIndex) => `
                  <img src="cid:${item.imageCid}-${imgIndex + 1}" alt="${item.name}" style="max-width: 150px; height: auto;">
                `).join('')}
              </li>
            `
              )
              .join('')}
          </ul>
          <p><b>Total Amount:</b> ₪${orderDetails.total}</p>
          <h3>Delivery Address:</h3>
          <p>${orderDetails.deliveryAddress}, ${orderDetails.city}</p>
          <p><b>Phone:</b> ${orderDetails.phoneNumber}</p>
          <p>Thank you for shopping with us!</p>
        </body>
      </html>
    `;

    // Prepare attachments (handling multiple images per item)
    const attachments = orderDetails.items
      .map((item, index) => {
        // Check if there are images for the current item
        if (!Array.isArray(item.imageUrl) || item.imageUrl.length === 0) {
          console.error(`No images found for item at index ${index}`);
          return null;
        }

        // Process each image in the imageUrl array
        return item.imageUrl.map((image, imgIndex) => {
          const imageBase64 = image?.data;

          if (!imageBase64) {
            console.error(`Missing or malformed image data for item at index ${index}, image index ${imgIndex}`);
            return null; // Skip this image if no valid Base64 data is found
          }

          // Convert Base64 string to buffer
          const imageBuffer = Buffer.from(imageBase64, 'base64');

          return {
            filename: `product-${index + 1}-image-${imgIndex + 1}.jpg`, // Unique filename for each image
            content: imageBuffer, // Binary content of the image
            cid: item.imageCid ? `${item.imageCid}-${imgIndex + 1}` : `image-${index + 1}-${imgIndex + 1}`, // Unique CID for each image
          };
        });
      })
      .flat() // Flatten the array since map returns an array of arrays (one per item)
      .filter(Boolean); // Remove null entries (i.e., those with missing or malformed image data)

    // Send the email with inline images as attachments
    await transporter.sendMail({
      from: 'rentitoutco@gmail.com',
      to: orderDetails.email,
      subject: 'Your Order Invoice',
      html: emailContent, // Email body in HTML format with inline images
      attachments: attachments, // Attachments array for inline images
    });

    // Respond with success
    res.status(200).json({ success: true, message: 'Order email sent successfully' });
  } catch (error) {
    console.error('Error sending order email:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

exports.sendOrderStatusUpdateMail = async (email, orderId, status) => {
  try {
    // Email content
    const emailContent = `
      <html>
        <body>
          <h2>Hello,</h2>
          <p>Your order with ID <strong>${orderId}</strong> has been updated to the following status: <strong>${status}</strong>.</p>
          <p>Thank you for shopping with us!</p>
        </body>
      </html>
    `;

    // Send the email
    await transporter.sendMail({
      from: 'rentitoutco@gmail.com',
      to: email,
      subject: 'Order Status Update',
      html: emailContent,
    });

    console.log(`Order status update email sent to ${email}`);
    return true;
  } catch (error) {
    console.error('Error sending order status update email:', error);
    return false;
  }
};



