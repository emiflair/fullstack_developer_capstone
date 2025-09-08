#!/usr/bin/env bash
set -xe
echo "===> ENTRYPOINT starting"
cd /app

# Wait a moment for DB if needed (cheap & cheerful)
python - <<'PY'
import time, sys
from django.core.management import execute_from_command_line
# quick ping via migrate dry-run (will fail fast if DB missing)
try:
    execute_from_command_line(["manage.py","showmigrations"])
except SystemExit:
    pass
time.sleep(1)
PY

# Migrate & collect static
python manage.py makemigrations --noinput || true
python manage.py migrate --noinput
python manage.py collectstatic --noinput || true

# Create superuser if missing (reads DJANGO_SUPERUSER_* env vars)
python - <<'PY'
import os
from django.contrib.auth import get_user_model
from django.core.management import call_command
import django
django.setup()
User = get_user_model()

u = os.environ.get("DJANGO_SUPERUSER_USERNAME")
p = os.environ.get("DJANGO_SUPERUSER_PASSWORD")
e = os.environ.get("DJANGO_SUPERUSER_EMAIL") or "admin@example.com"

if u and p:
    if not User.objects.filter(username=u).exists():
        print(f"[entrypoint] creating superuser {u}")
        call_command(
            "createsuperuser",
            interactive=False,
            username=u,
            email=e
        )
        # set password (createsuperuser --noinput doesn't take password)
        usr = User.objects.get(username=u)
        usr.set_password(p); usr.is_staff = True; usr.is_superuser = True; usr.save()
    else:
        print(f"[entrypoint] superuser {u} already exists")
else:
    print("[entrypoint] DJANGO_SUPERUSER_* not set; skipping superuser creation")
PY

# Hand off to gunicorn/runserver (whatever CMD supplies)
exec "$@"
