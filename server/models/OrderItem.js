const mongoose = require('mongoose');

const OrderItemSchema = new mongoose.Schema({
  orderId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Order', 
    required: true 
  },
  itemName: { 
    type: String, 
    required: true 
  },
  quantity: { 
    type: Number, 
    required: true, 
    min: 1 
  },
  price: { 
    type: Number, 
    required: true, 
    min: 0 
  }
});

module.exports = mongoose.model('OrderItem', OrderItemSchema);