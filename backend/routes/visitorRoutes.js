const express = require('express');
const router = express.Router();
const {
  registerVisitor,
  getVisitors,
  getVisitorById,
  updateVisitorStatus,
  checkInVisitor,
  checkOutVisitor,
  getVisitorQRCode,
} = require('../controllers/visitorController');
const { protect, securityOrAdmin } = require('../middleware/authMiddleware');

router.route('/')
  .post(protect, registerVisitor)
  .get(protect, securityOrAdmin, getVisitors);

router.route('/:id').get(protect, getVisitorById);
router.route('/:id/qrcode.png').get(getVisitorQRCode);

router.route('/:id/status').put(protect, securityOrAdmin, updateVisitorStatus);
router.route('/:id/checkin').put(protect, securityOrAdmin, checkInVisitor);
router.route('/:id/checkout').put(protect, securityOrAdmin, checkOutVisitor);

module.exports = router;
