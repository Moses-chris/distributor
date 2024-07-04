const mongoose = require('mongoose');

const OrderItemSchema = new mongoose.Schema({
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
  itemName: String,
  quantity: Number,
  price: Number,
});

module.exports = mongoose.model('OrderItem', OrderItemSchema);