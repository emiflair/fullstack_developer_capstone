"""
Django settings for djangoproj project.
"""

import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

# -------------------------------------------------------------------
# Core
# -------------------------------------------------------------------
SECRET_KEY = 'django-insecure-ccow$tz_=9%dxu4(0%^(z%nx32#s@(zt9$ih@)5l54yny)wm-0'
DEBUG = True

# The Skills Network proxy gives you an HTTPS host like:
# https://<user>-8000.theidockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai
ALLOWED_HOSTS = [
    "127.0.0.1",
    "localhost",
    "[::1]",
    "0.0.0.0",
    "django_backend",
    "dealership_django",
    ".theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai",
]

# Tell Django the proxy in front terminates TLS so request.is_secure() works
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

# Trust the lab proxy origin for CSRF (wildcard subdomain)
CSRF_TRUSTED_ORIGINS = [
    "https://*.theiadockernext-0-labs-prod-theiak8s-4-tor01.proxy.cognitiveclass.ai",
]

# -------------------------------------------------------------------
# Apps
# -------------------------------------------------------------------
INSTALLED_APPS = [
    "djangoapp.apps.DjangoappConfig",
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

# -------------------------------------------------------------------
# Middleware  (ensure CsrfViewMiddleware is present for admin/login)
# -------------------------------------------------------------------
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",  # needed for admin/auth
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "djangoproj.urls"

# -------------------------------------------------------------------
# Templates (we serve the React build with Django)
# -------------------------------------------------------------------
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [
            os.path.join(BASE_DIR, "frontend/static"),
            os.path.join(BASE_DIR, "frontend/build"),
            os.path.join(BASE_DIR, "frontend/build/static"),
        ],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "djangoproj.wsgi.application"

# -------------------------------------------------------------------
# Database (lab uses SQLite for Django-side models)
# -------------------------------------------------------------------
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
    }
}

# -------------------------------------------------------------------
# Password validation
# -------------------------------------------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# -------------------------------------------------------------------
# i18n
# -------------------------------------------------------------------
LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_L10N = True
USE_TZ = True

# -------------------------------------------------------------------
# Static / Media
# -------------------------------------------------------------------
STATIC_URL = "/static/"
STATIC_ROOT = os.path.join(BASE_DIR, "static")
MEDIA_ROOT = os.path.join(STATIC_ROOT, "media")
MEDIA_URL = "/media/"

STATICFILES_DIRS = [
    os.path.join(BASE_DIR, "frontend/static"),
    os.path.join(BASE_DIR, "frontend/build"),
    os.path.join(BASE_DIR, "frontend/build/static"),
]

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# -------------------------------------------------------------------
# Sessions / Cookies (work over HTTPS through the proxy)
# -------------------------------------------------------------------
SESSION_COOKIE_SECURE = False  # Set to False for local development
CSRF_COOKIE_SECURE = False     # Set to False for local development
SESSION_COOKIE_SAMESITE = "Lax"
CSRF_COOKIE_SAMESITE = "Lax"

# Optional but nice-to-have defaults
LOGIN_URL = "/admin/login/"
LOGIN_REDIRECT_URL = "/admin/"

# If you ever add DRF later, keep this empty to use session auth
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [],  # frontend uses session cookie
}
