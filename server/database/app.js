// server/database/app.js
const express = require("express");
const fs = require("fs");
const path = require("path");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 3030;

// ---------- middleware ----------
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// ---------- load seed data ----------
const reviewsPath = path.join(__dirname, "data", "reviews.json");
const dealershipsPath = path.join(__dirname, "data", "dealerships.json");
const reviewsSeed = JSON.parse(fs.readFileSync(reviewsPath, "utf8"));
const dealershipsSeed = JSON.parse(fs.readFileSync(dealershipsPath, "utf8"));

// Store data in memory for simple operation without MongoDB
let reviews = reviewsSeed.reviews || [];
let dealerships = dealershipsSeed.dealerships || [];

console.log(`[api] Loaded ${reviews.length} reviews and ${dealerships.length} dealerships from files`);

// ---------- routes ----------
app.get("/", (_req, res) => res.send("Welcome to the JSON API"));
app.get("/healthz", (_req, res) => res.json({ ok: true }));

// --- Reviews ---
app.get("/fetchReviews", (_req, res) => {
  try {
    res.json(reviews);
  } catch {
    res.status(500).json({ error: "Error fetching reviews" });
  }
});

app.get("/fetchReviews/dealer/:id", (req, res) => {
  try {
    const dealerId = Number(req.params.id);
    const filteredReviews = reviews.filter(review => review.dealership === dealerId);
    res.json(filteredReviews);
  } catch {
    res.status(500).json({ error: "Error fetching reviews" });
  }
});

// --- Dealers ---
app.get("/fetchDealers", (_req, res) => {
  try {
    res.json(dealerships);
  } catch {
    res.status(500).json({ error: "Error fetching dealerships" });
  }
});

app.get("/fetchDealers/:state", (req, res) => {
  try {
    const state = req.params.state;
    const filteredDealers = dealerships.filter(dealer => 
      dealer.state === state || dealer.state.toLowerCase() === state.toLowerCase()
    );
    res.json(filteredDealers);
  } catch {
    res.status(500).json({ error: "Error fetching dealerships" });
  }
});

app.get("/fetchDealer/:id", (req, res) => {
  try {
    const dealerId = Number(req.params.id);
    const dealer = dealerships.find(d => d.id === dealerId);
    if (!dealer) return res.status(404).json({ error: "Dealer not found" });
    res.json(dealer);
  } catch {
    res.status(500).json({ error: "Error fetching dealer" });
  }
});

// --- Insert review ---
app.post("/insert_review", (req, res) => {
  try {
    let data = req.body;
    if (typeof data === "string") {
      try { data = JSON.parse(data); } catch { data = {}; }
    }
    if (!data || typeof data !== "object") data = {};

    // coerce/sanitize
    const name = (data.name ?? "").toString().trim() || "Anonymous";
    const dealership = Number(data.dealership) || 0;
    const reviewText = (data.review ?? "").toString().trim();
    const purchase = !!data.purchase;
    const purchase_date = (data.purchase_date ?? "").toString();
    const car_make = (data.car_make ?? "").toString().trim();
    const car_model = (data.car_model ?? "").toString().trim();
    const car_year = data.car_year === "" || data.car_year == null ? null : Number(data.car_year);

    // next incremental id
    const maxId = reviews.length > 0 ? Math.max(...reviews.map(r => r.id || 0)) : 0;
    const new_id = maxId + 1;

    const newReview = {
      id: new_id,
      name,
      dealership,
      review: reviewText,
      purchase,
      purchase_date,
      car_make,
      car_model,
      car_year,
    };

    reviews.push(newReview);
    res.status(201).json(newReview);
  } catch (err) {
    res.status(400).json({ error: "Error inserting review", details: err.message });
  }
});

// ---------- start ----------
app.listen(PORT, "0.0.0.0", () =>
  console.log(`[api] Server is running on http://0.0.0.0:${PORT}`)
);
