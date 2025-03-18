require("dotenv").config();
const express = require("express");
const routes = require("./routes/routes");
const sequelize = require("./config/config");

const app = express();
const PORT = process.env.PORT || 8080;
const ENV = process.env.NODE_ENV || "development";

// Middleware
app.use(express.json({strict : true}));
app.use((req,res,next) => {
    if(Object.keys(req.query).length > 0){
        console.error("Query Parameters not allowed");
        res.set("Cache-Control", "no-cache");
        return res.status(400).send();
    }
    next();
});
app.use((err,req,res,next) => {
    if(err instanceof SyntaxError && err.status === 400 && "body" in err){
        console.error("Invalid JSON payload received");
        res.set("Cache-Control", "no-cache");
        return res.status(400).send();
    }
    next();
});

// Routes
app.use("/", routes);
app.use((req,res) => {
    console.error("Invalid API endpoint");
    res.status(404).send();
});

// Bootstrapping Database
(async () => {
    try {
        await sequelize.sync();
        console.log("Database Synced Successfully");
    } catch (error) {
        console.error("Error syncing Database:", error);
    }
})();

if (ENV !== "test") {
    app.listen(PORT, async () => {
        try {
            await sequelize.authenticate();
            console.log(`Server is running on http://localhost:${PORT}`);
        } catch (error) {
            console.error("Database connection failed:", error);
            process.exit(1);
        }
    });
}
module.exports = app;