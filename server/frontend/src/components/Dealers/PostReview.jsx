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
      <div style={{ 
        padding: "40px 20px",
        maxWidth: "900px",
        margin: "0 auto",
        backgroundColor: "#f5f5f5",
        minHeight: "100vh"
      }}>
        <div style={{
          backgroundColor: "white",
          borderRadius: "12px",
          boxShadow: "0 8px 24px rgba(0,0,0,0.1)",
          overflow: "hidden"
        }}>
          {/* Header */}
          <div style={{
            background: "linear-gradient(135deg, #23e0e0 0%, #1ac6c6 100%)",
            color: "white",
            padding: "30px",
            textAlign: "center"
          }}>
            <h1 style={{
              margin: "0",
              fontSize: "28px",
              fontWeight: "600"
            }}>
              Write a Review
            </h1>
            <p style={{
              margin: "10px 0 0 0",
              fontSize: "18px",
              opacity: "0.9"
            }}>
              {dealer ? dealer.full_name : "Loading dealer..."}
            </p>
          </div>

          {/* Form Content */}
          <div style={{ padding: "40px" }}>
            {/* Review Text Area */}
            <div style={{ marginBottom: "30px" }}>
              <label style={{ 
                display: "block", 
                marginBottom: "12px", 
                fontSize: "16px",
                fontWeight: "600",
                color: "#333"
              }}>
                Your Review <span style={{ color: "#e74c3c" }}>*</span>
              </label>
              <textarea
                id="review"
                placeholder="Share your experience with this dealership. What did you like? What could be improved?"
                required
                value={review}
                onChange={(e) => setReview(e.target.value)}
                style={{
                  width: "100%",
                  minHeight: "140px",
                  padding: "16px",
                  border: "2px solid #e0e0e0",
                  borderRadius: "8px",
                  fontSize: "16px",
                  resize: "vertical",
                  fontFamily: "inherit",
                  lineHeight: "1.5",
                  boxSizing: "border-box"
                }}
              />
            </div>

            {/* Vehicle Information Section */}
            <div style={{ 
              backgroundColor: "#f8f9fa", 
              padding: "25px", 
              borderRadius: "12px", 
              marginBottom: "30px",
              border: "1px solid #e9ecef"
            }}>
              <h3 style={{ 
                margin: "0 0 20px 0", 
                color: "#23e0e0", 
                fontSize: "20px",
                fontWeight: "600"
              }}>
                🚗 Vehicle Information
              </h3>
              
              <div style={{ 
                display: "grid", 
                gridTemplateColumns: "2fr 1fr", 
                gap: "20px",
                alignItems: "end"
              }}>
                {/* Car Make & Model */}
                <div>
                  <label style={{ 
                    display: "block", 
                    marginBottom: "8px", 
                    fontSize: "14px",
                    fontWeight: "600",
                    color: "#555"
                  }}>
                    Car Make & Model <span style={{ color: "#e74c3c" }}>*</span>
                  </label>
                  <select
                    name="cars"
                    id="cars"
                    required
                    value={model}
                    onChange={(e) => setModel(e.target.value)}
                    style={{
                      width: "100%",
                      padding: "12px 16px",
                      border: "2px solid #e0e0e0",
                      borderRadius: "8px",
                      fontSize: "16px",
                      backgroundColor: "white",
                      boxSizing: "border-box"
                    }}
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

                {/* Car Year */}
                <div>
                  <label style={{ 
                    display: "block", 
                    marginBottom: "8px", 
                    fontSize: "14px",
                    fontWeight: "600",
                    color: "#555"
                  }}>
                    Car Year <span style={{ color: "#e74c3c" }}>*</span>
                  </label>
                  <input
                    type="number"
                    required
                    value={year}
                    onChange={(e) => setYear(e.target.value)}
                    max={new Date().getFullYear()}
                    min={2010}
                    placeholder="2023"
                    style={{
                      width: "100%",
                      padding: "12px 16px",
                      border: "2px solid #e0e0e0",
                      borderRadius: "8px",
                      fontSize: "16px",
                      boxSizing: "border-box"
                    }}
                  />
                </div>
              </div>
            </div>

            {/* Purchase Information */}
            <div style={{ marginBottom: "40px" }}>
              <label style={{ 
                display: "block", 
                marginBottom: "8px", 
                fontSize: "16px",
                fontWeight: "600",
                color: "#333"
              }}>
                📅 Purchase Date <span style={{ color: "#e74c3c" }}>*</span>
              </label>
              <input
                type="date"
                required
                value={date}
                onChange={(e) => setDate(e.target.value)}
                style={{
                  padding: "12px 16px",
                  border: "2px solid #e0e0e0",
                  borderRadius: "8px",
                  fontSize: "16px",
                  width: "200px",
                  boxSizing: "border-box"
                }}
              />
            </div>

            {/* Submit Button */}
            <div style={{ 
              textAlign: "center", 
              paddingTop: "20px",
              borderTop: "1px solid #e9ecef"
            }}>
              <button 
                onClick={postreview} 
                disabled={posting}
                style={{
                  backgroundColor: posting ? "#bbb" : "#23e0e0",
                  color: "white",
                  border: "none",
                  padding: "16px 48px",
                  fontSize: "18px",
                  fontWeight: "600",
                  borderRadius: "50px",
                  cursor: posting ? "not-allowed" : "pointer",
                  transition: "all 0.3s ease",
                  boxShadow: posting ? "none" : "0 4px 12px rgba(35, 224, 224, 0.3)",
                  transform: posting ? "none" : "translateY(0)",
                  minWidth: "200px"
                }}
                onMouseOver={(e) => {
                  if (!posting) {
                    e.target.style.backgroundColor = "#1ac6c6";
                    e.target.style.transform = "translateY(-2px)";
                    e.target.style.boxShadow = "0 6px 16px rgba(35, 224, 224, 0.4)";
                  }
                }}
                onMouseOut={(e) => {
                  if (!posting) {
                    e.target.style.backgroundColor = "#23e0e0";
                    e.target.style.transform = "translateY(0)";
                    e.target.style.boxShadow = "0 4px 12px rgba(35, 224, 224, 0.3)";
                  }
                }}
              >
                {posting ? "⏳ Posting Review..." : "✨ Post Review"}
              </button>
            </div>

            {/* Required fields note */}
            <div style={{ 
              marginTop: "25px", 
              textAlign: "center", 
              color: "#888",
              fontSize: "14px",
              fontStyle: "italic"
            }}>
              <span style={{ color: "#e74c3c" }}>*</span> Required fields
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
