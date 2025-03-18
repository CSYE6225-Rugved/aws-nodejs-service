const { S3Client, DeleteObjectCommand } = require("@aws-sdk/client-s3");
const multer = require("multer");
const multerS3 = require("multer-s3");
const { File } = require("../models/model");
require("dotenv").config();

//AWS S3 configuratrion 
const s3 = new S3Client({
    region: process.env.AWS_REGION,
    credentials: process.env.AWS_ACCESS_KEY_ID
        ? {
              accessKeyId: process.env.AWS_ACCESS_KEY_ID,
              secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
          }
        : undefined, // Use IAM Role on EC2 or AWS Profile locally
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
    try {
        if (!req.file) {
            return res.status(400).json({ error: "No file uploaded" });
        }

        //Save file metadata in MySQL
        const newFile = await File.create({
            file_name: req.file.originalname,
            s3_key: req.file.key,
            s3_url: `https://${process.env.AWS_S3_BUCKET_NAME}.s3.amazonaws.com/${req.file.key}`,
        });

        res.status(201).json({
            id: newFile.id,
            file_name: newFile.file_name,
            s3_url: newFile.s3_url,
            upload_date: newFile.upload_date,
        });
    } catch (error) {
        console.error("File upload error:", error);
        res.status(500).json({ error: "Internal Server Error", details: error.message });
    }
};

// Get File API
const getFile = async (req, res) => {
    try {
        const file = await File.findByPk(req.params.id);
        if (!file) {
            return res.status(404).json({ error: "File not found" });
        }

        res.status(200).json({
            id: file.id,
            file_name: file.file_name,
            s3_url: file.s3_url,
            upload_date: file.upload_date,
        });
    } catch (error) {
        console.error("File retrieval error:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};


// Delete File API
const deleteFile = async (req, res) => {
    try {
        const file = await File.findByPk(req.params.id);
        if (!file) {
            return res.status(404).json({ error: "File not found" });
        }

        const deleteParams = {
            Bucket: process.env.AWS_S3_BUCKET_NAME,
            Key: file.s3_key,
        };

        await s3.send(new DeleteObjectCommand(deleteParams));

        await file.destroy();

        res.status(204).send();
    } catch (error) {
        console.error(" File deletion error:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
};

module.exports = { upload, uploadFile, getFile, deleteFile};