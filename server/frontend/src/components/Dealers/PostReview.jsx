// frontend/src/components/Dealers/PostReview.jsx
import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import "./Dealers.css";
import "../assets/style.css";
import Header from "../Header/Header";

export default function PostReview() {
  const { id } = useParams();                     // dealer id (string)
  const dealerId = Number(id);

  // UI state
  const [dealer, setDealer] = useState(null);
  const [review, setReview] = useState("");
  const [model, setModel] = useState("");         // "MAKE|MODEL"
  const [year, setYear] = useState("");
  const [date, setDate] = useState("");
  const [carmodels, setCarmodels] = useState([]);
  const [posting, setPosting] = useState(false);

  // API endpoints
  const dealer_url    = `/djangoapp/dealer/${dealerId}/`;
  const review_url    = `/djangoapp/add_review/`;
  const carmodels_url = `/djangoapp/get_cars/`;

  // ---- helpers ----
  const getNameFromSession = () => {
    const fn = sessionStorage.getItem("firstname") || "";
    const ln = sessionStorage.getItem("lastname") || "";
    let name = `${fn} ${ln}`.trim();
    if (!name || name.toLowerCase().includes("null")) {
      name = sessionStorage.getItem("username") || "Anonymous";
    }
    return name;
  };

  // ---- data loads ----
  const get_dealer = async () => {
    try {
      const res = await fetch(dealer_url);
      const data = await res.json();
      const list = Array.isArray(data.dealer) ? data.dealer : data.dealer ? [data.dealer] : [];
      setDealer(list[0] || null);
    } catch (e) {
      console.error("dealer fetch error:", e);
    }
  };

  const get_cars = async () => {
    try {
      const res = await fetch(carmodels_url, { method: "GET" });
      const data = await res.json();
      const list = Array.isArray(data.cars) ? data.cars : [];
      setCarmodels(list);
    } catch (e) {
      console.error("car models fetch error:", e);
    }
  };

  useEffect(() => {
    get_dealer();
    get_cars();
  }, [dealerId]);

  // ---- submit ----
  const postreview = async () => {
    if (posting) return;

    const name = getNameFromSession();
    const thisYear = new Date().getFullYear();

    // quick client validation
    if (!review.trim() || !date || !model || !year) {
      alert("All details are mandatory (review, date, make/model, year).");
      return;
    }
    const yearNum = Number(year);
    if (!Number.isFinite(yearNum) || yearNum < 2010 || yearNum > thisYear) {
      alert(`Car year must be between 2010 and ${thisYear}`);
      return;
    }

    const [make_chosen_raw, model_chosen_raw] = (model || "").split("|");
    const car_make  = (make_chosen_raw  || "").trim();
    const car_model = (model_chosen_raw || "").trim();
    if (!car_make || !car_model) {
      alert("Choose a valid car make and model.");
      return;
    }

    // exact payload that /insert_review expects (Django proxies to it)
    const payload = {
      name,
      dealership: dealerId,
      review: review.trim(),
      purchase: true,
      purchase_date: date,     // "YYYY-MM-DD"
      car_make,
      car_model,
      car_year: yearNum,
    };

    setPosting(true);
    try {
      const res = await fetch(review_url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include", // keep session cookie for @login_required
        body: JSON.stringify(payload),
      });

      const text = await res.text();
      let json = {};
      try { json = JSON.parse(text || "{}"); } catch {}

      // tolerate the usual success shapes from your view/backend
      const ok =
        res.ok ||
        json?.status === 200 ||
        json?.ok === true ||
        json?._id || json?.id || json?.insertedId;

      if (ok) {
        // hard navigate with cache-buster so new review shows immediately
        window.location.href = `${window.location.origin}/dealer/${dealerId}?t=${Date.now()}`;
      } else {
        console.warn("POST /djangoapp/add_review/ failed:", res.status, json, text, payload);
        alert(json?.message || "Posting review failed. Please try again.");
      }
    } catch (e) {
      console.error("Network error posting review:", e);
      alert("Network error while posting review.");
    } finally {
      setPosting(false);
    }
  };

  return (
    <div>
      <Header />
      <div style={{ margin: "5%" }}>
        <h1 style={{ color: "darkblue" }}>
          {dealer ? dealer.full_name : "Loading dealer..."}
        </h1>

        <label htmlFor="review" className="block mb-2">Your Review</label>
        <textarea
          id="review"
          cols="50"
          rows="7"
          required
          value={review}
          onChange={(e) => setReview(e.target.value)}
        />

        <div className="input_field">
          Purchase Date{" "}
          <input
            type="date"
            required
            value={date}
            onChange={(e) => setDate(e.target.value)}
          />
        </div>

        <div className="input_field">
          Car Make &amp; Model
          <select
            name="cars"
            id="cars"
            required
            value={model}
            onChange={(e) => setModel(e.target.value)}
          >
            <option value="" disabled hidden>
              Choose Car Make and Model
            </option>
            {carmodels.map((c, idx) => (
              <option
                key={`${c.CarMake}-${c.CarModel}-${idx}`}
                value={`${c.CarMake}|${c.CarModel}`}
              >
                {c.CarMake} {c.CarModel}
              </option>
            ))}
          </select>
        </div>

        <div className="input_field">
          Car Year{" "}
          <input
            type="number"
            required
            value={year}
            onChange={(e) => setYear(e.target.value)}
            max={new Date().getFullYear()}
            min={2010}
          />
        </div>

        <div>
          <button className="postreview" onClick={postreview} disabled={posting}>
            {posting ? "Posting..." : "Post Review"}
          </button>
        </div>
      </div>
    </div>
  );
}
