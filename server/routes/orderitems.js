const express = require('express');
const router = express.Router();
const orderItemController = require('../controllers/orderitemController');

// Create a new order item
router.post('/', orderItemController.createOrderItem);

// Get all order items
router.get('/', orderItemController.getAllOrderItems);

// Get order items for a specific order
router.get('/order/:orderId', orderItemController.getOrderItemsByOrderId);

// Get a single order item by ID
router.get('/:id', orderItemController.getOrderItemById);

// Update an order item
router.put('/:id', orderItemController.updateOrderItem);

// Delete an order item
router.delete('/:id', orderItemController.deleteOrderItem);

module.exports = router;