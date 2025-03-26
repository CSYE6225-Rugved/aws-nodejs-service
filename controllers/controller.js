const HealthCheck = require("../models/model.js").HealthCheck;
const { log } = require("console");
const logger = require("./../logger.js")

// Health check logic
exports.healthCheck = async (req, res) => {
    if(Object.keys(req.body).length !==0){
        console.error("Invalid Payload");
        res.set("Cache-Control", "no-cache");
        return res.status(400).send();
    }
    try {
        await HealthCheck.create({});
        logger.info({
            message: "Health Check Successful",
            httpRequest: {
                requestMethod: req.method,
                requestUrl: req.originalUrl,
                status: 200,
            }
        })
        console.log("Health Check Successful");
        res.set("Cache-Control", "no-cache");
        return res.status(200).json();
    } catch (error) {
        logger.error({
            message: "Health Check Failed",
            httpRequest: {
                requestMethod: req.method,
                requestUrl: req.originalUrl,
                status: 503,
            }
        })
        console.error("Health check failed:", error);
        res.set("Cache-Control", "no-cache");
        return res.status(503).send();
    }
};

//unsupported methods
exports.handleUnsupportedMethods = (req, res) => {
    logger.error({
        message: "Unsupported Method",
        httpRequest: {
            requestMethod: req.method,
            requestUrl: req.originalUrl,
            status: 405,
        }
    })
    console.error("Unsupported Method");
    res.set("Cache-Control", "no-cache");
    return res.status(405).send();
};
