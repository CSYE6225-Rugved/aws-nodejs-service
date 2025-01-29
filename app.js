require("dotenv").config();
const express = require("express");
const routes = require("./routes/routes");
const sequelize = require("./config/config");

const app = express();
const PORT = process.env.PORT || 8080;

// Start the server
const server = app.listen(PORT, async () => {
    try {
        await sequelize.authenticate();
        console.log(`Server is running on http://localhost:${PORT}`);
    } catch (error) {
        console.error("Database connection failed:", error);
        process.exit(1);
    }
});

// Middleware
app.use(express.json());

// Routes
app.use("/", routes);

