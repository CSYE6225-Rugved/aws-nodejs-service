const express = require("express");
const router = express.Router();
const healthController = require("../controllers/controller");

// Define routes
router.get("/healthCheck", healthController.healthCheck);
router.all("/healthCheck", healthController.handleUnsupportedMethods);

module.exports = router;