const HealthCheck = require("../models/model.js").HealthCheck;

// Health check logic
exports.healthCheck = async (req, res) => {
    if(Object.keys(req.body).length !==0){
        console.error("Invalid Payload");
        res.set("Cache-Control", "no-cache");
        return res.status(400).send();
    }
    try {
        await HealthCheck.create({});
        console.log("Health Check Successful");
        res.set("Cache-Control", "no-cache");
        return res.status(200).json();
    } catch (error) {
        console.error("Health check failed:", error);
        res.set("Cache-Control", "no-cache");
        return res.status(503).send();
    }
};

//unsupported methods
exports.handleUnsupportedMethods = (req, res) => {
    res.set("Cache-Control", "no-cache");
    return res.status(405).send();
};
