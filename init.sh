#!/bin/bash

# start Xvfb
/usr/bin/Xvfb :0 -screen 0 1280x720x16 &

# start fluxbox
fluxbox -display :0 &

# start x11vnc
x11vnc -display :0 -bg -forever -usepw -localhost -xkb -rfbport 5900 &

# generate self-signed certificate for SSL/TLS encryption
openssl req -new -x509 -days 365 -nodes -out self.pem -keyout self.pem -subj "/C=US/ST=/L=/O=/CN="

# start noVNC
/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 --web /usr/share/novnc/ --ssl-only &

# start orange-canvas, QT_AUTO_SCREEN_SCALE_FACTOR=0 is to prevent crashing when loading add-ons
QT_AUTO_SCREEN_SCALE_FACTOR=0 orange-canvas --no-splash --no-welcome &

# keep the container running even through restarts of Orange
while :; do sleep 1; done