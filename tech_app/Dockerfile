FROM python:3.8-slim

# Intencional: rodar como root (más prática)
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Intencional: embutir secret em ENV (detectar secret in code/ENV)
ENV API_KEY "AKIA_TEST_HARDCODED_PLACEHOLDER"

EXPOSE 5000
CMD ["python", "app.py"]
