import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import "./Dealers.css";
import "../assets/style.css";
import positive_icon from "../assets/positive.png";
import neutral_icon from "../assets/neutral.png";
import negative_icon from "../assets/negative.png";
import review_icon from "../assets/reviewbutton.png";
import Header from "../Header/Header";

export default function Dealer() {
  const { id } = useParams();

  const [dealer, setDealer] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [unreviewed, setUnreviewed] = useState(false);

  const dealer_url = `/djangoapp/dealer/${id}/`;
  const reviews_url = `/djangoapp/reviews/dealer/${id}/`;
  const post_review = `/postreview/${id}`;
  const isLoggedIn = !!sessionStorage.getItem("username");

  const get_dealer = async () => {
    const res = await fetch(dealer_url);
    const data = await res.json();
    if (data.status === 200) {
      setDealer(data.dealer || data);
    } else {
      console.error("dealer fetch failed", data);
    }
  };

  const get_reviews = async () => {
    const res = await fetch(reviews_url);
    const data = await res.json();
    if (data.status === 200) {
      if (Array.isArray(data.reviews) && data.reviews.length > 0) {
        setReviews(data.reviews);
      } else {
        setUnreviewed(true);
      }
    } else {
      console.error("reviews fetch failed", data);
    }
  };

  const senti_icon = (sentiment) =>
    sentiment === "positive" ? positive_icon :
    sentiment === "negative" ? negative_icon :
    neutral_icon;

  useEffect(() => {
    (async () => {
      try { await get_dealer(); } catch (e) { console.error(e); }
      try { await get_reviews(); } catch (e) { console.error(e); }
    })();
  }, [id]);

  return (
    <div style={{ margin: 20 }}>
      <Header />
      <div style={{ marginTop: 10 }}>
        <h1 style={{ color: "grey" }}>
          {dealer?.full_name || ""}{" "}
          {isLoggedIn && (
            <a href={post_review}>
              <img
                src={review_icon}
                style={{ width: "10%", marginLeft: 10, marginTop: 10 }}
                alt="Post Review"
              />
            </a>
          )}
        </h1>
        {dealer && (
          <h4 style={{ color: "grey" }}>
            {dealer.city}, {dealer.address}, Zip - {dealer.zip}, {dealer.state}
          </h4>
        )}
      </div>

      <div className="reviews_panel">
        {reviews.length === 0 && !unreviewed ? (
          <span>Loading Reviews…</span>
        ) : unreviewed ? (
          <div>No reviews yet!</div>
        ) : (
          reviews.map((review, idx) => (
            <div key={idx} className="review_panel">
              <img src={senti_icon(review.sentiment)} className="emotion_icon" alt="Sentiment" />
              <div className="review">{review.review}</div>
              <div className="reviewer">
                {review.name} {review.car_make} {review.car_model} {review.car_year}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
