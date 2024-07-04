const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');

// Create a new order
router.post('/', orderController.createOrder);

// Get all orders
router.get('/', orderController.getAllOrders);

// Get a single order by ID
router.get('/:id', orderController.getOrderById);

// Update an order
router.put('/:id', orderController.updateOrder);

// Delete an order
router.delete('/:id', orderController.deleteOrder);

module.exports = router;