const OrderItem = require('../models/OrderItem');
const Order = require('../models/Order');

exports.createOrderItem = async (req, res) => {
  try {
    const { orderId, itemName, quantity, price } = req.body;
    
    // Check if the order exists
    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    const orderItem = new OrderItem({
      orderId,
      itemName,
      quantity,
      price
    });

    const savedOrderItem = await orderItem.save();

    // Update the order's total amount
    order.totalAmount += quantity * price;
    await order.save();

    res.status(201).json(savedOrderItem);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getAllOrderItems = async (req, res) => {
  try {
    const orderItems = await OrderItem.find();
    res.json(orderItems);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getOrderItemsByOrderId = async (req, res) => {
  try {
    const orderItems = await OrderItem.find({ orderId: req.params.orderId });
    res.json(orderItems);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getOrderItemById = async (req, res) => {
  try {
    const orderItem = await OrderItem.findById(req.params.id);
    if (!orderItem) return res.status(404).json({ message: 'Order item not found' });
    res.json(orderItem);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateOrderItem = async (req, res) => {
  try {
    const { itemName, quantity, price } = req.body;
    const orderItem = await OrderItem.findById(req.params.id);
    
    if (!orderItem) return res.status(404).json({ message: 'Order item not found' });

    // Calculate the difference in total amount
    const order = await Order.findById(orderItem.orderId);
    const oldTotal = orderItem.quantity * orderItem.price;
    const newTotal = quantity * price;
    const difference = newTotal - oldTotal;

    // Update the order item
    orderItem.itemName = itemName;
    orderItem.quantity = quantity;
    orderItem.price = price;

    const updatedOrderItem = await orderItem.save();

    // Update the order's total amount
    order.totalAmount += difference;
    await order.save();

    res.json(updatedOrderItem);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.deleteOrderItem = async (req, res) => {
  try {
    const orderItem = await OrderItem.findById(req.params.id);
    if (!orderItem) return res.status(404).json({ message: 'Order item not found' });

    // Update the order's total amount
    const order = await Order.findById(orderItem.orderId);
    order.totalAmount -= orderItem.quantity * orderItem.price;
    await order.save();

    await orderItem.remove();
    res.json({ message: 'Order item deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};