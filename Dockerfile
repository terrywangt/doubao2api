FROM python:3.12-slim

WORKDIR /app

# Chinese fonts + VNC stack for manual login/captcha handling
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        fonts-liberation \
        fonts-wqy-microhei \
        fonts-wqy-zenhei \
        ca-certificates \
        xvfb \
        x11vnc \
        novnc \
        websockify \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && python -m playwright install --with-deps chromium

COPY doubao2api/ doubao2api/
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV DOUBAO_HOST=0.0.0.0
ENV DOUBAO_PORT=9090
ENV DISPLAY=:99

EXPOSE 9090 6080

ENTRYPOINT ["/app/entrypoint.sh"]