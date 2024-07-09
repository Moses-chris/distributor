const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
  uuid: { type: String, required: true, unique: true },
  bakerName: String,
  status: String,
  deliveryDate: Date,
  totalAmount: Number,
  orderItems: [{ type: mongoose.Schema.Types.ObjectId, ref: 'OrderItem' }]
});

OrderSchema.index({ uuid: 1 }, { unique: true });

module.exports = mongoose.model('Order', OrderSchema);