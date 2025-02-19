const request = require("supertest");
const app = require("../app");
const sequelize = require("../config/config");

let server;

beforeAll(async () => {
    server = app.listen(4000);
    await sequelize.sync();
});

afterAll(async () => {
    await sequelize.close();
    server.close();
});

describe("API Tests", () => {
    test("GET /healthz should return 200", async () => {
        const response = await request(app).get("/healthz");
        expect(response.status).toBe(202);
    });

    test("POST /healthz should return 405", async () => {
        const response = await request(app).post("/healthz").send();
        expect(response.status).toBe(405);
    });

    test("PUT /healthz should return 405 for unsupported method", async () => {
        const response = await request(app).put("/healthz");
        expect(response.status).toBe(405);
    });

    test("DELETE /healthz should return 405 for unsupported method", async () => {
        const response = await request(app).delete("/healthz");
        expect(response.status).toBe(405);
    });

    test("GET /healthz with query parameters should return 400", async () => {
        const response = await request(app).get("/healthz?param=test");
        expect(response.status).toBe(400);
    });

    test("POST /healthz with invalid JSON should return 400", async () => {
        const response = await request(app)
            .post("/healthz")
            .set("Content-Type", "application/json")
            .send("{invalid json}");
        expect(response.status).toBe(400);
    });

    test("GET to non-existent endpoint should return 404", async () => {
        const response = await request(app).get("/nonexistent");
        expect(response.status).toBe(404);
    });

    test("PATCH /healthz should return 405 for unsupported method", async () => {
        const response = await request(app).patch("/healthz");
        expect(response.status).toBe(405);
    });

    test("HEAD /healthz should return 405 for unsupported method", async () => {
        const response = await request(app).head("/healthz");
        expect(response.status).toBe(405);
    });

    test("OPTIONS /healthz should return 405 for unsupported method", async () => {
        const response = await request(app).options("/healthz");
        expect(response.status).toBe(405);
    });

    test("POST /healthz with empty payload should return 405", async () => {
        const response = await request(app)
            .post("/healthz")
            .send({});
        expect(response.status).toBe(405);
    });
});
