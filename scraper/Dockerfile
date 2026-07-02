FROM python:3.12-slim

WORKDIR /app

# Install dependencies first so Docker can cache this layer independently
# from the source code — rebuilds after code-only changes skip the pip step.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY scraper.py .

# -u disables Python's output buffer so every log.info() line streams to
# Cloud Run's log viewer immediately rather than appearing in one burst at exit.
CMD ["uvicorn", "scraper:app", "--host", "0.0.0.0", "--port", "8080"]
