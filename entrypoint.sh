#!/bin/sh
set -e

# ── Browser profile lock cleanup ──
# Chromium refuses to open a profile whose SingletonLock names a different
# host (a rebuilt container is always a different host). Nothing else can be
# holding this profile: one browser per container, and it is not running yet.
# Only the lock trio is touched, never the session data beside it.
PROFILE="${DOUBAO_BROWSER_DATA:-/root/.doubao_browser}"
rm -f "${PROFILE}/SingletonLock" "${PROFILE}/SingletonCookie" "${PROFILE}/SingletonSocket" 2>/dev/null || true

echo "Starting Xvfb on :99..."
# 上次异常退出会遗留 X 锁，Xvfb 会拒绝启动——先清理再起
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true
Xvfb :99 -screen 0 1280x800x24 -ac +extension GLX +render -noreset > /tmp/xvfb.log 2>&1 &
XVFB_PID=$!

# 等待 Xvfb 真正就绪(最多 15s)
i=0
while [ $i -lt 15 ]; do
    [ -S /tmp/.X11-unix/X99 ] && break
    sleep 1
    i=$((i+1))
done
[ -S /tmp/.X11-unix/X99 ] || { echo "Xvfb failed to start"; cat /tmp/xvfb.log; exit 1; }
echo "Xvfb ready (socket X99)"

export DISPLAY=:99

echo "Starting x11vnc..."
x11vnc -display :99 -forever -shared -nopw -quiet -bg -o /tmp/x11vnc.log 2>/dev/null || true
sleep 1

echo "Starting websockify noVNC on :6080..."
websockify --web=/usr/share/novnc 6080 localhost:5900 > /tmp/websockify.log 2>&1 &
WS_PID=$!
sleep 1

echo "VNC stack ready: Xvfb(:99) + x11vnc(:5900) + noVNC(:6080)"

# 启动主服务
exec python -m doubao2api