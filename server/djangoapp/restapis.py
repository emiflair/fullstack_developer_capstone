# server/djangoapp/restapis.py
import os
import requests
from urllib.parse import urlencode, quote_plus
from pathlib import Path

# Load .env as a fallback only (do NOT override real env provided by K8s)
try:
    from dotenv import load_dotenv
    load_dotenv(dotenv_path=Path(__file__).with_name(".env"), override=False)
except Exception:
    pass  # optional in production

def _env(name: str, default: str = "") -> str:
    return os.environ.get(name, default).strip()

def _norm_base(url: str) -> str:
    return (url or "").rstrip("/")

BACKEND_URL = _norm_base(_env("BACKEND_URL", "http://localhost:3030"))
SENT_BASE   = _norm_base(_env("sentiment_analyzer_url"))

if not BACKEND_URL:
    raise RuntimeError("backend_url is not set (env or .env)")
if not SENT_BASE:
    raise RuntimeError("sentiment_analyzer_url is not set (env or .env)")

print(f"[restapis] BACKEND_URL = {BACKEND_URL}")
print(f"[restapis] SENT_URL    = {SENT_BASE}")

def _join(base: str, endpoint: str) -> str:
    ep = endpoint if endpoint.startswith("/") else f"/{endpoint}"
    return f"{base}{ep}"

def get_request(endpoint: str, **params):
    """GET the Node/Mongo backend."""
    url = _join(BACKEND_URL, endpoint)
    if params:
        url = f"{url}?{urlencode(params)}"
    print(f"[restapis] GET {url}")
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        ct = (r.headers.get("content-type") or "").lower()
        return r.json() if "application/json" in ct else r.text
    except Exception as e:
        print("[restapis] GET error:", e)
        return None

def analyze_review_sentiments(text: str):
    """GET the sentiment analyzer microservice."""
    url = _join(SENT_BASE, f"analyze/{quote_plus(text or '')}")
    print(f"[restapis] SENT {url}")
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        return r.json()
    except Exception as e:
        print("[restapis] SENT error:", e)
        return {"sentiment": "neutral"}

def post_review(data: dict):
    """POST a review to the Node/Mongo backend."""
    url = _join(BACKEND_URL, "insert_review")
    print(f"[restapis] POST {url}")
    try:
        r = requests.post(url, json=data, timeout=10)
        r.raise_for_status()
        ct = (r.headers.get("content-type") or "").lower()
        return r.json() if "application/json" in ct else r.text
    except Exception as e:
        print("[restapis] POST error:", e)
        return {"status": "error", "error": str(e)}
