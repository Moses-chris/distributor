const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
  bakerName: String,
  status: String,
  deliveryDate: Date,
  totalAmount: Number,
});

module.exports = mongoose.model('Order', OrderSchema);