const { Sequelize, DataTypes } = require("sequelize");
const sequelize = require("../config/config");

const HealthCheck = sequelize.define(
    "HealthCheck",
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },
        datetime: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW,
        }
    },
    {
        timestamps: false 
    }
);

const File = sequelize.define(
    "File",
    {
        id: {
            type: DataTypes.UUID,
            defaultValue: Sequelize.UUIDV4,
            primaryKey: true,
        },
        file_name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        s3_key: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        s3_url: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        upload_date: {
            type: DataTypes.DATEONLY,
            defaultValue: DataTypes.NOW,
        },
    },
    {
        timestamps: false,
        tableName: "files",
    }
);
module.exports = {HealthCheck, File};
