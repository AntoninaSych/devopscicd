FROM python:3.10-slim

# Workdir inside container
WORKDIR /app

# (Optional) small runtime deps for psycopg2-binary
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 curl \
    && rm -rf /var/lib/apt/lists/*

# Install python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# These ENV may be overridden by env_file from compose
ENV POSTGRES_HOST=${POSTGRES_HOST}
ENV POSTGRES_PORT=${POSTGRES_PORT}
ENV POSTGRES_DB=${POSTGRES_DB}
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

# Copy app sources
COPY . .

EXPOSE 8000

# Dev server (for prod лучше gunicorn/uvicorn)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
