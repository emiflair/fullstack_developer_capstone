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

# Primary backend URL from environment
BACKEND_URL = _norm_base(_env("BACKEND_URL", "http://localhost:3030"))
SENT_BASE   = _norm_base(_env("sentiment_analyzer_url"))

# Fallback URLs for cloud environments
FALLBACK_URLS = [
    "https://emifeaustin0-3030.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai",
    "http://host.docker.internal:3030",
    "http://localhost:3030",
    "http://127.0.0.1:3030",
]

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
    """GET the Node/Mongo backend with fallback URLs."""
    urls_to_try = [BACKEND_URL] + FALLBACK_URLS
    
    for base_url in urls_to_try:
        url = _join(base_url, endpoint)
        if params:
            url = f"{url}?{urlencode(params)}"
        print(f"[restapis] GET {url}")
        try:
            r = requests.get(url, timeout=10)
            r.raise_for_status()
            ct = (r.headers.get("content-type") or "").lower()
            result = r.json() if "application/json" in ct else r.text
            print(f"[restapis] SUCCESS with {base_url}")
            return result
        except Exception as e:
            print(f"[restapis] GET error with {base_url}: {e}")
            continue
    
    print("[restapis] All URLs failed")
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
    """POST a review to the Node/Mongo backend with fallback URLs."""
    urls_to_try = [BACKEND_URL] + FALLBACK_URLS
    
    for base_url in urls_to_try:
        url = _join(base_url, "insert_review")
        print(f"[restapis] POST {url}")
        try:
            r = requests.post(url, json=data, timeout=10)
            r.raise_for_status()
            ct = (r.headers.get("content-type") or "").lower()
            result = r.json() if "application/json" in ct else r.text
            print(f"[restapis] POST SUCCESS with {base_url}")
            return result
        except Exception as e:
            print(f"[restapis] POST error with {base_url}: {e}")
            continue
    
    print("[restapis] All POST URLs failed")
    return {"status": "error", "error": "All backend URLs failed"}
