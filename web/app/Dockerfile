FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

EXPOSE 5000
# 1 worker suffit largement pour une salle de formation.
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
