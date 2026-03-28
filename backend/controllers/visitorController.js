const Visitor = require('../models/Visitor');
const QRCode = require('qrcode');

// @desc    Register new visitor
// @route   POST /api/visitors
// @access  Private (Admin, Security, User)
const registerVisitor = async (req, res) => {
  try {
    const { name, phone, purpose, date, time } = req.body;

    const visitor = await Visitor.create({
      name,
      phone,
      purpose,
      date,
      time,
      registeredBy: req.user._id,
    });

    // Generate QR Code containing Visitor ID
    const qrData = JSON.stringify({ visitorId: visitor._id });
    const qrCodeImage = await QRCode.toDataURL(qrData);

    visitor.qrCode = qrCodeImage;
    await visitor.save();

    req.io.emit('new_visitor', visitor);

    res.status(201).json(visitor);
  } catch (error) {
    res.status(400).json({ message: 'Failed to register visitor', error: error.message });
  }
};

// @desc    Get all visitors
// @route   GET /api/visitors
// @access  Private (Admin, Security)
const getVisitors = async (req, res) => {
  try {
    const visitors = await Visitor.find({}).populate('registeredBy', 'name email');
    res.json(visitors);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Get visitor by ID
// @route   GET /api/visitors/:id
// @access  Private
const getVisitorById = async (req, res) => {
  try {
    const visitor = await Visitor.findById(req.params.id).populate('registeredBy', 'name email');
    if (visitor) {
      res.json(visitor);
    } else {
      res.status(404).json({ message: 'Visitor not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Update visitor status (Approve/Reject)
// @route   PUT /api/visitors/:id/status
// @access  Private (Admin, Security)
const updateVisitorStatus = async (req, res) => {
  try {
    const { status } = req.body; // 'Approved' or 'Rejected'
    const visitor = await Visitor.findById(req.params.id);

    if (visitor) {
      visitor.status = status;
      const updatedVisitor = await visitor.save();
      
      req.io.emit('visitor_status_updated', updatedVisitor);
      res.json(updatedVisitor);
    } else {
      res.status(404).json({ message: 'Visitor not found' });
    }
  } catch (error) {
    res.status(400).json({ message: 'Invalid status update', error: error.message });
  }
};

// @desc    Mark visitor entry (Check In)
// @route   PUT /api/visitors/:id/checkin
// @access  Private (Security)
const checkInVisitor = async (req, res) => {
  try {
    const visitor = await Visitor.findById(req.params.id);

    if (visitor) {
      if (visitor.status !== 'Approved') {
        req.io.emit('unauthorized_access', { message: `Unauthorized entry attempt by ${visitor.name}` });
        return res.status(403).json({ message: 'Visitor not approved' });
      }

      visitor.checkIn = new Date();
      const updatedVisitor = await visitor.save();

      req.io.emit('visitor_checkin', updatedVisitor);
      res.json(updatedVisitor);
    } else {
      res.status(404).json({ message: 'Visitor not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error check-in' });
  }
};

// @desc    Mark visitor exit (Check Out)
// @route   PUT /api/visitors/:id/checkout
// @access  Private (Security)
const checkOutVisitor = async (req, res) => {
  try {
    const visitor = await Visitor.findById(req.params.id);

    if (visitor) {
      if (!visitor.checkIn) {
        return res.status(400).json({ message: 'Visitor has not checked in yet' });
      }

      visitor.checkOut = new Date();
      const updatedVisitor = await visitor.save();

      req.io.emit('visitor_checkout', updatedVisitor);
      res.json(updatedVisitor);
    } else {
      res.status(404).json({ message: 'Visitor not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error check-out' });
  }
};

// @desc    Serve raw visitor QR code Image
// @route   GET /api/visitors/:id/qrcode.png
// @access  Public
const getVisitorQRCode = async (req, res) => {
  try {
    const visitor = await Visitor.findById(req.params.id);
    if (visitor && visitor.qrCode) {
      const base64Data = visitor.qrCode.replace(/^data:image\/png;base64,/, "");
      const img = Buffer.from(base64Data, 'base64');
      res.writeHead(200, {
        'Content-Type': 'image/png',
        'Content-Length': img.length
      });
      res.end(img);
    } else {
      res.status(404).send('Not found');
    }
  } catch (error) {
    res.status(500).send('Server error');
  }
};

module.exports = {
  registerVisitor,
  getVisitors,
  getVisitorById,
  updateVisitorStatus,
  checkInVisitor,
  checkOutVisitor,
  getVisitorQRCode,
};
