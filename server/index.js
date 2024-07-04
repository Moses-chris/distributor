const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
}));
app.use(express.json());

// Connect to MongoDB
const mongoUri = 'mongodb+srv://moseschris535:moseschris@try1.vi7vgwz.mongodb.net/';

mongoose.connect(mongoUri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  ssl: true,
  sslValidate: true,
  tlsAllowInvalidCertificates: false,
  tlsAllowInvalidHostnames: false,
});

// mongoose.set('strictQuery', true); // Set this to true or false as needed
const db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', () => console.log('Connected to MongoDB'));

// Routes
// Orders route (if you have one)


app.use('/api/orders', require('./routes/orders'));
//app.use('/api/orderItems', require('./routes/orderItems'));
//app.use('/api/receipts', require('./routes/receipts'));
//app.use('/api/payments', require('./routes/payments'));

const PORT = process.env.PORT || 5080;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));