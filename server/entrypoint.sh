#!/usr/bin/env bash
set -xe
echo "===> ENTRYPOINT starting"
cd /app

# Ensure Django knows which settings to use
export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-djangoproj.settings}"

# Quick check that DB is reachable (optional)
python - <<'PY'
import time, django
django.setup()
from django.core.management import call_command
try:
    call_command("showmigrations")
except Exception as e:
    print("[entrypoint] showmigrations error:", e)
time.sleep(1)
PY

# Migrate & collect static (safe if DB is up)
python manage.py makemigrations --noinput || true
python manage.py migrate --noinput || true
python manage.py collectstatic --noinput || true

# Create superuser if env provided
python - <<'PY'
import os, django
django.setup()
from django.contrib.auth import get_user_model

User = get_user_model()
u = os.environ.get("DJANGO_SUPERUSER_USERNAME", "emifeaustin")
p = os.environ.get("DJANGO_SUPERUSER_PASSWORD", "dealership123")
e = os.environ.get("DJANGO_SUPERUSER_EMAIL", "emifeaustin0909@gmail.com")

if u and p:
    if not User.objects.filter(username=u).exists():
        print(f"[entrypoint] creating superuser {u}")
        user = User.objects.create_user(username=u, email=e, password=p)
        user.is_staff = True
        user.is_superuser = True
        user.save()
        print(f"[entrypoint] superuser {u} created successfully!")
    else:
        print(f"[entrypoint] superuser {u} already exists")
        # Update password in case it changed
        user = User.objects.get(username=u)
        user.set_password(p)
        user.save()
        print(f"[entrypoint] superuser {u} password updated")
else:
    print("[entrypoint] DJANGO_SUPERUSER_* not set; skipping superuser creation")
PY

# Hand off to CMD (gunicorn)
exec "$@"
