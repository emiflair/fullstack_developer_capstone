# server/djangoapp/views.py

import json
import logging
from datetime import datetime

from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.timezone import now

from .models import CarMake, CarModel
from .populate import initiate
from .restapis import get_request, analyze_review_sentiments, post_review

logger = logging.getLogger(__name__)

# ---------------------------------------------------------
# Authentication (login/logout/register)
# ---------------------------------------------------------

@csrf_exempt
def login_user(request):
    """
    Expects JSON: {"userName": "...", "password": "..."}
    Returns: {"userName": "...", "status": "Authenticated"} on success
    """
    if request.method != "POST":
        return JsonResponse({"detail": "Method not allowed"}, status=405)

    try:
        payload = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"detail": "Invalid JSON"}, status=400)

    username = payload.get("userName") or payload.get("username") or ""
    password = payload.get("password") or ""
    user = authenticate(username=username, password=password)
    if user is None:
        return JsonResponse({"status": "Unauthorized"}, status=401)

    login(request, user)
    return JsonResponse({"userName": username, "status": "Authenticated"})


@csrf_exempt
def logout_user(request):
    """Ends current session. Accepts GET or POST for the lab."""
    if request.method not in ("GET", "POST"):
        return JsonResponse({"detail": "Method not allowed"}, status=405)
    logout(request)
    return JsonResponse({"status": "logged out"})


@csrf_exempt
def register_user(request):
    """
    Registers a new user. Expects JSON with username + password.
    On success, logs the user in immediately.
    """
    if request.method != "POST":
        return JsonResponse({"detail": "Method not allowed"}, status=405)

    try:
        data = json.loads(request.body.decode("utf-8"))
    except Exception:
        return JsonResponse({"detail": "Invalid JSON"}, status=400)

    username   = data.get("username") or data.get("userName")
    password   = data.get("password")
    first_name = data.get("first_name") or data.get("firstName") or ""
    last_name  = data.get("last_name")  or data.get("lastName")  or ""
    email      = data.get("email") or ""

    if not username or not password:
        return JsonResponse(
            {"detail": "username and password are required"}, status=400
        )
    if User.objects.filter(username=username).exists():
        return JsonResponse({"status": "exists"}, status=409)

    user = User.objects.create_user(
        username=username,
        password=password,
        first_name=first_name,
        last_name=last_name,
        email=email,
    )
    login(request, user)
    return JsonResponse({"userName": username, "status": "Registered"}, status=201)

# ---------------------------------------------------------
# Dealerships / Reviews
# ---------------------------------------------------------

def get_dealerships(request, state="All"):
    """List all dealers, or filter by ?state=XX."""
    qs_state = request.GET.get("state")
    if qs_state:
        state = qs_state

    endpoint = "/fetchDealers" if state in (None, "", "All") else f"/fetchDealers/{state}"
    dealerships = get_request(endpoint)
    return JsonResponse({"status": 200, "dealers": dealerships})


def get_dealer_reviews(request, dealer_id):
    """Return dealer reviews, enriched with sentiment analysis."""
    if not dealer_id:
        return JsonResponse({"status": 400, "message": "Bad Request"})

    reviews = get_request(f"/fetchReviews/dealer/{dealer_id}") or []
    enriched = []
    if isinstance(reviews, list):
        for r in reviews:
            txt = (r.get("review") or "").strip()
            try:
                result = analyze_review_sentiments(txt) if txt else {}
            except Exception:
                result = {}
            r["sentiment"] = (result or {}).get("sentiment", "neutral")
            enriched.append(r)

    return JsonResponse({"status": 200, "reviews": enriched})


def get_dealer_details(request, dealer_id):
    """Return details for one dealer."""
    if not dealer_id:
        return JsonResponse({"status": 400, "message": "Bad Request"})
    dealership = get_request(f"/fetchDealer/{dealer_id}")
    return JsonResponse({"status": 200, "dealer": dealership})


@csrf_exempt
def add_review(request):
    """
    Accepts POST JSON from frontend.
    Builds payload for Node/Mongo backend, posts it, then
    returns updated reviews so UI refreshes immediately.
    """
    if request.method != "POST":
        return JsonResponse(
            {"status": 405, "message": "Method not allowed"}, status=405
        )

    if not request.user.is_authenticated:
        return JsonResponse({"status": 403, "message": "Unauthorized"}, status=403)

    try:
        body = (request.body or b"").decode("utf-8")
        data = json.loads(body) if body else {}
    except Exception:
        return JsonResponse({"status": 400, "message": "Invalid JSON"}, status=400)

    dealer_id   = (data.get("dealership") or data.get("dealerId")
                   or data.get("dealer_id") or data.get("id"))
    review_txt  = data.get("review") or ""
    name        = data.get("name") or request.user.username

    purchase      = bool(data.get("purchase", False))
    purchase_date = data.get("purchase_date") or ""
    car_make      = data.get("car_make") or ""
    car_model     = data.get("car_model") or ""
    car_year      = data.get("car_year") or ""

    if not dealer_id or not str(review_txt).strip():
        return JsonResponse(
            {"status": 400, "message": "dealer_id and review are required"},
            status=400,
        )

    doc = {
        "name":          name,
        "dealership":    int(dealer_id),
        "review":        review_txt.strip(),
        "purchase":      purchase,
        "purchase_date": str(purchase_date),
        "car_make":      str(car_make),
        "car_model":     str(car_model),
        "car_year":      str(car_year),
        "time":          now().strftime("%Y-%m-%dT%H:%M:%SZ"),
    }

    try:
        backend_resp = post_review(doc)
    except Exception as e:
        return JsonResponse(
            {"status": 502, "message": f"backend error: {e}"}, status=502
        )

    ok = False
    if isinstance(backend_resp, dict):
        if backend_resp.get("ok") or backend_resp.get("acknowledged"):
            ok = True
        if backend_resp.get("status") in (200, 201):
            ok = True
        if backend_resp.get("_id") or backend_resp.get("insertedId") or backend_resp.get("id"):
            ok = True
        if not ok and backend_resp:
            ok = True

    if not ok:
        return JsonResponse(
            {"status": 502, "message": "backend_failed", "body": backend_resp},
            status=502,
        )

    try:
        updated = get_request(f"/fetchReviews/dealer/{int(dealer_id)}") or []
    except Exception:
        updated = []

    return JsonResponse(
        {"status": 200, "reviews": updated, "backend": backend_resp}, status=200
    )

# ---------------------------------------------------------
# Cars (Django ORM seeded models)
# ---------------------------------------------------------

def get_cars(request):
    """Return list of cars from Django DB. Populate DB on first call if empty."""
    if request.method != "GET":
        return JsonResponse({"detail": "Method not allowed"}, status=405)

    if not CarModel.objects.exists():
        try:
            initiate()
        except Exception as e:
            return JsonResponse({"detail": f"Init failed: {e}"}, status=500)

    car_models = CarModel.objects.select_related("car_make").all()
    cars = [{"CarModel": cm.name, "CarMake": cm.car_make.name} for cm in car_models]
    return JsonResponse({"cars": cars})
