const { S3Client, DeleteObjectCommand } = require("@aws-sdk/client-s3");
const multer = require("multer");
const multerS3 = require("multer-s3");
const { File } = require("../models/model");
const logger = require("../logger");
const { log } = require("console");
const statsd = require("../utils/statsd");
require("dotenv").config();


//AWS S3 configuratrion 
const s3 = new S3Client({
    region: process.env.AWS_REGION,
});

//Multer configuration for file upload
const upload = multer({
    storage: multerS3({
        s3: s3,
        bucket: process.env.AWS_S3_BUCKET_NAME,
        acl: "private",
        metadata: (req, file, cb) => {
            cb(null, { fieldName: file.fieldname });
        },
        key: (req, file, cb) => {
            const fileKey = `${Date.now()}-${file.originalname}`;
            cb(null, fileKey);
        },
    }),
});

// Upload File API
const uploadFile = async (req, res) => {
    console.log("Incoming File:", req.file);
    const apiStart = Date.now();
    statsd.increment("api.uploadFile.hit"); 
    try {
        if (!req.file) {
            statsd.timing("api.uploadFile.duration", Date.now() - apiStart);
            logger.error({
                message: "No file uploaded",
                httpRequest: {
                    requestMethod: req.method,
                    requestUrl: req.originalUrl,
                    status: 400,
                },
            });
            return res.status(400).json({ error: "No file uploaded" });
        }

        const dbStart = Date.now();
        //Save file metadata in MySQL
        const newFile = await File.create({
            file_name: req.file.originalname,
            s3_key: req.file.key,
            s3_url: `${process.env.AWS_S3_BUCKET_NAME}`,
            upload_date: new Date().toISOString().split("T")[0],
        });

        statsd.timing("db.insertFile.duration", Date.now() - dbStart);
        statsd.timing("api.uploadFile.duration", Date.now() - apiStart);
        logger.info({
            message: "File uploaded successfully",
            httpRequest: {
                requestMethod: req.method,
                requestUrl: req.originalUrl,
                status: 201,
            },
        });
        res.status(201).json({
            id: newFile.id,
            file_name: newFile.file_name,
            url: `${newFile.s3_url}/${newFile.id}/${newFile.file_name}`,
            upload_date: newFile.upload_date,
        });
    } catch (error) {
        statsd.timing("api.uploadFile.duration", Date.now() - apiStart);
        logger.error({
            message: "File upload failed",
            error: error,
            httpRequest: {
                requestMethod: req.method,
                requestUrl: req.originalUrl,
                status: 503,
            },
        });
        console.error("File upload error:", error);
        res.status(503).json();;
    }
};

// Get File API
const getFile = async (req, res) => {
    const apiStart = Date.now();
    statsd.increment("api.getFile.hit");
    try {
        if (Object.keys(req.body).length > 0) {
            statsd.timing("api.getFile.duration", Date.now() - apiStart);
            logger.error({
                message: "Body not allowed in GET request",
                httpRequest: {
                    requestMethod: req.method,
                    requestUrl: req.originalUrl,
                    status: 400,
                },
            });
            console.error("Body not allowed in GET request");
            return res.status(400).json();
        }
        const dbStart = Date.now();
        const file = await File.findByPk(req.params.id);
        statsd.timing("db.getFileById.duration", Date.now() - dbStart);
        if (!file) {
            return res.status(404).json({ error: "File not found" });
        }
        statsd.timing("api.getFile.duration", Date.now() - apiStart);
        logger.info({
            message: "File retrieved successfully",
            httpRequest: {
                requestMethod: req.method,
                requestUrl: req.originalUrl,
                status: 200,
            },
        });
        res.status(200).json({
            id: file.id,
            file_name: file.file_name,
            url: `${file.s3_url}/${file.id}/${file.file_name}`,
            upload_date: file.upload_date,
        });
    } catch (error) {
        statsd.timing("api.getFile.duration", Date.now() - apiStart);
        logger.error({
            message: "File retrieval failed",
            error: error,
            httpRequest: {
                requestMethod: req.method,
                requestUrl: req.originalUrl,
                status: 503,
            },
        });
        console.error("File retrieval error:", error);
        res.status(503).json();
    }
};


// Delete File API
const deleteFile = async (req, res) => {
    const apiStart = Date.now();
    statsd.increment("api.deleteFile.hit");
    try {
        const dbStart = Date.now();
        const file = await File.findByPk(req.params.id);
        statsd.timing("db.getFileById.duration", Date.now() - dbStart);
        if (!file) {
            return res.status(404).json({ error: "File not found" });
        }
        const s3Start = Date.now();
        const deleteParams = {
            Bucket: process.env.AWS_S3_BUCKET_NAME,
            Key: file.s3_key,
        };

        await s3.send(new DeleteObjectCommand(deleteParams));

        statsd.timing("s3.deleteObject.duration", Date.now() - s3Start);

        const dbDeleteStart = Date.now();
        await file.destroy();
        statsd.timing("db.deleteFile.duration", Date.now() - dbDeleteStart);

        statsd.timing("api.deleteFile.duration", Date.now() - apiStart);
        logger.info({
            message: "File deleted successfully",
            httpRequest: {
                requestMethod: req.method,
                requestUrl: req.originalUrl,
                status: 204,
            },
        });
        res.status(204).send();
    } catch (error) {
        statsd.timing("api.deleteFile.duration", Date.now() - apiStart);
        logger.error({
            message: "File deletion failed",
            error: error,
            httpRequest: {
                requestMethod: req.method,
                requestUrl: req.originalUrl,
                status: 503,
            },
        });
        console.error(" File deletion error:", error);
        res.status(503).json();;
    }
};

module.exports = { upload, uploadFile, getFile, deleteFile};