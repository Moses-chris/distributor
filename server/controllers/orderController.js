const Order = require('../models/Order');
const logger = require('../utils/logger');
const OrderItem = require('../models/OrderItem');

exports.createOrder = async (req, res) => {
  try {
    const { uuid, orderItems, ...orderData } = req.body;
    logger.info(`Received order sync request for UUID: ${uuid}`);

    // Check if an order with this UUID already exists
    let existingOrder = await Order.findOne({ uuid });

    let savedOrder;

    if (existingOrder) {
      logger.info(`Order with UUID: ${uuid} already exists. Updating...`);
      // Update only if the incoming data is newer
      if (orderData.updatedAt && new Date(orderData.updatedAt) > existingOrder.updatedAt) {
        Object.assign(existingOrder, orderData);
        savedOrder = await existingOrder.save();
        logger.info(`Order updated successfully for UUID: ${uuid}`);
      } else {
        logger.info(`Existing order is newer or same. Skipping update for UUID: ${uuid}`);
        savedOrder = existingOrder;
      }
    } else {
      logger.info(`No existing order found for UUID: ${uuid}. Creating new order...`);
      // Create new order
      const newOrder = new Order({ uuid, ...orderData });
      savedOrder = await newOrder.save();
      logger.info(`New order created successfully for UUID: ${uuid}`);
    }

    // Handle OrderItems
    if (orderItems && orderItems.length > 0) {
      // Remove existing order items
      await OrderItem.deleteMany({ orderId: savedOrder._id });

      // Create new OrderItems
      const createdOrderItems = await OrderItem.insertMany(
        orderItems.map(item => ({ ...item, orderId: savedOrder._id }))
      );

      // Add OrderItem references to the Order
      savedOrder.orderItems = createdOrderItems.map(item => item._id);
      await savedOrder.save();

      logger.info(`OrderItems updated for UUID: ${uuid}`);
    }

    // Log the total number of orders after this operation
    const totalOrders = await Order.countDocuments();
    logger.info(`Total number of orders in the database: ${totalOrders}`);

    res.status(existingOrder ? 200 : 201).json(savedOrder);

  } catch (error) {
    logger.error(`Error in createOrder: ${error.message}`);
    res.status(500).json({ error: error.message });
  }
};

// // exports.createOrder = async (req, res) => {
// //   try {
// //     const { uuid, ...orderData } = req.body;
// //     logger.info(`Received order sync request for UUID: ${uuid}`);

// //     // Check if an order with this UUID already exists
// //     let existingOrder = await Order.findOne({ uuid });

// //     if (existingOrder) {
// //       logger.info(`Order with UUID: ${uuid} already exists. Updating...`);
// //       // Update only if the incoming data is newer
// //       if (orderData.updatedAt && new Date(orderData.updatedAt) > existingOrder.updatedAt) {
// //         Object.assign(existingOrder, orderData);
// //         await existingOrder.save();
// //         logger.info(`Order updated successfully for UUID: ${uuid}`);
// //       } else {
// //         logger.info(`Existing order is newer or same. Skipping update for UUID: ${uuid}`);
// //       }
// //       res.json(existingOrder);
// //     } else {
// //       logger.info(`No existing order found for UUID: ${uuid}. Creating new order...`);
// //       // Create new order
// //       const newOrder = new Order({ uuid, ...orderData });
// //       await newOrder.save();
// //       logger.info(`New order created successfully for UUID: ${uuid}`);
// //       res.status(201).json(newOrder);
// //     }

// //     // Log the total number of orders after this operation
// //     const totalOrders = await Order.countDocuments();
// //     logger.info(`Total number of orders in the database: ${totalOrders}`);

// //   } catch (error) {
// //     logger.error(`Error in createOrder: ${error.message}`);
// //     res.status(500).json({ error: error.message });
// //   }
// // };
// exports.createOrder = async (req, res) => {
//   try {
//     const { uuid, bakerName, status, deliveryDate, totalAmount, orderItems } = req.body;
    
//     const order = new Order({
//       uuid,
//       bakerName,
//       status,
//       deliveryDate,
//       totalAmount
//     });

//     const savedOrder = await order.save();

//     // Create OrderItems
//     if (orderItems && orderItems.length > 0) {
//       const createdOrderItems = await OrderItem.insertMany(
//         orderItems.map(item => ({ ...item, orderId: savedOrder._id }))
//       );

//       // Add OrderItem references to the Order
//       savedOrder.orderItems = createdOrderItems.map(item => item._id);
//       await savedOrder.save();
//     }

//     res.status(201).json(savedOrder);
//   } catch (error) {
//     res.status(400).json({ message: error.message });
//   }
// };

exports.getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find();
    logger.info(`Retrieved ${orders.length} orders`);
    res.json(orders);
  } catch (error) {
    logger.error(`Error in getAllOrders: ${error.message}`);
    res.status(500).json({ message: error.message });
  }
};

exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      logger.warn(`Order not found for ID: ${req.params.id}`);
      return res.status(404).json({ message: 'Order not found' });
    }
    logger.info(`Retrieved order for ID: ${req.params.id}`);
    res.json(order);
  } catch (error) {
    logger.error(`Error in getOrderById: ${error.message}`);
    res.status(500).json({ message: error.message });
  }
};

exports.updateOrder = async (req, res) => {
  try {
    const updatedOrder = await Order.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true, runValidators: true }
    );
    if (!updatedOrder) {
      logger.warn(`Order not found for update, ID: ${req.params.id}`);
      return res.status(404).json({ message: 'Order not found' });
    }
    logger.info(`Order updated successfully, ID: ${req.params.id}`);
    res.json(updatedOrder);
  } catch (error) {
    logger.error(`Error in updateOrder: ${error.message}`);
    res.status(400).json({ message: error.message });
  }
};

exports.deleteOrder = async (req, res) => {
  try {
    const deletedOrder = await Order.findByIdAndDelete(req.params.id);
    if (!deletedOrder) {
      logger.warn(`Order not found for deletion, ID: ${req.params.id}`);
      return res.status(404).json({ message: 'Order not found' });
    }
    logger.info(`Order deleted successfully, ID: ${req.params.id}`);
    res.json({ message: 'Order deleted successfully' });
  } catch (error) {
    logger.error(`Error in deleteOrder: ${error.message}`);
    res.status(500).json({ message: error.message });
  }
};