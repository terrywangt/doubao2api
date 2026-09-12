FROM python:3.12-slim

WORKDIR /app

# Chinese fonts for Doubao page rendering
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        fonts-liberation \
        fonts-wqy-microhei \
        fonts-wqy-zenhei \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && python -m playwright install --with-deps chromium

COPY doubao2api/ doubao2api/

ENV DOUBAO_HOST=0.0.0.0
ENV DOUBAO_PORT=9090

EXPOSE 9090

CMD ["python", "-m", "doubao2api"]