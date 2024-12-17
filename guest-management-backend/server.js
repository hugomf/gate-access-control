const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();

// Middleware
app.use(bodyParser.json());
app.use(cors());

// MongoDB Connection
const uri = 'mongodb+srv://guest_admin:DUaF7eL0WiUBeMs0@cluster0.faf6e.mongodb.net/guest_management?retryWrites=true&w=majority';
mongoose
  .connect(uri)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error(err));
// Guest Schema
const guestSchema = new mongoose.Schema({
  name: String,
  phone: String,
  reason: String,
  createdAt: { type: Date, default: Date.now },
});

const Guest = mongoose.model('Guest', guestSchema);

// Routes
app.post('/api/guests', async (req, res) => {
  const { email, name, phone, reason } = req.body;
  const guest = new Guest({ email, name, phone, reason });
  await guest.save();
  res.status(201).send(guest);
});

app.get('/api/guests', async (req, res) => {
  const guests = await Guest.find();
  res.send(guests);
});

// DELETE /api/guests/:id
app.delete('/api/guests/:id', async (req, res) => {
  const guestId = req.params.id;

  try {
    // Find the guest by ID and delete
    const guest = await Guest.findByIdAndDelete(guestId);

    if (!guest) {
      return res.status(404).json({ message: 'Guest not found' });
    }

    res.status(200).json({ message: 'Guest deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// PUT /api/guests/:id - Update a guest
app.put('/api/guests/:id', async (req, res) => {
  const guestId = req.params.id;
  const { name, phone, email, reason } = req.body;

  try {
    // Find the guest by ID and update it
    const updatedGuest = await Guest.findByIdAndUpdate(
      guestId,
      { name, phone, email, reason }, // New data to update
      { new: true } // Return the updated guest
    );

    if (!updatedGuest) {
      return res.status(404).json({ message: 'Guest not found' });
    }

    res.status(200).json(updatedGuest);  // Send the updated guest object back
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Start the server
const port = 5001;
app.listen(port, () => console.log(`Server running on port ${port}`));
