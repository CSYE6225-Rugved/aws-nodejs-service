const { DataTypes } = require("sequelize");
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


// // Bootstrapping Database
// (async () => {
//     try {
//         await sequelize.sync();
//         console.log("HealthCheck table Synced Successfully");
//     } catch (error) {
//         console.error("Error syncing the HealthCheck table:", error);
//     }
// })();

module.exports = HealthCheck;
