FROM python:3.12.0-slim-bookworm

# Use key=value form (no warnings) and standard Python env vars
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP=/app

WORKDIR $APP

# Install the requirements
COPY requirements.txt $APP/
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the rest
COPY . $APP

EXPOSE 8000

RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
CMD ["gunicorn", "--bind", ":8000", "--workers", "3", "djangoproj.wsgi"]
