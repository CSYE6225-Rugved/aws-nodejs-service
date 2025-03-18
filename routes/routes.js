const express = require("express");
const router = express.Router();
const healthController = require("../controllers/controller");
const fileController = require("../controllers/fileController");

// Define routes
router.head("/healthz", healthController.handleUnsupportedMethods);
router.get("/healthz", healthController.healthCheck);
router.all("/healthz", healthController.handleUnsupportedMethods);

router.head("/v1/file", healthController.handleUnsupportedMethods);
router.post("/v1/file", fileController.upload.single('file'), fileController.uploadFile);
router.all("/v1/file", healthController.handleUnsupportedMethods);

router.head("/v1/file/:id", healthController.handleUnsupportedMethods);
router.get("/v1/file/:id", fileController.getFile);
router.all("/v1/file/:id", healthController.handleUnsupportedMethods);

router.delete("/v1/file/:id", fileController.deleteFile);
module.exports = router;