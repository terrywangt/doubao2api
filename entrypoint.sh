#!/bin/sh
set -e

# 启动 Xvfb 虚拟显示
echo "Starting Xvfb on :99..."
Xvfb :99 -screen 0 1280x800x24 -ac +extension GLX +render -noreset > /tmp/xvfb.log 2>&1 &
XVFB_PID=$!
sleep 2

export DISPLAY=:99

# 启动 x11vnc (VNC over Xvfb)
echo "Starting x11vnc..."
x11vnc -display :99 -forever -shared -nopw -quiet -bg -o /tmp/x11vnc.log 2>/dev/null || \
x11vnc -display :99 -forever -shared -nopw -quiet -o /tmp/x11vnc.log &
sleep 2

# 启动 websockify → noVNC (端口 6080)
echo "Starting websockify noVNC on :6080..."
websockify --web=/usr/share/novnc 6080 localhost:5900 > /tmp/websockify.log 2>&1 &
WS_PID=$!
sleep 2

echo "VNC stack ready: Xvfb(:99) + x11vnc(:5900) + noVNC(:6080)"

# 启动主服务
exec python -m doubao2api