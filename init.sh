#!/bin/bash

echo "Starting xvfb..."
/usr/bin/Xvfb :0 -screen 0 1280x720x16 &

fluxbox -display :0 &

echo "Starting x11vnc..."
mkdir -p ~/.vnc
x11vnc -storepasswd "$1" ~/.vnc/passwd
x11vnc -display :0 -bg -forever -usepw -localhost -xkb -rfbport 5900 &

openssl req -new -x509 -days 365 -nodes -out self.pem -keyout self.pem -subj "/C=US/ST=/L=/O=/CN="

/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 --web /usr/share/novnc/ --ssl-only &

QT_AUTO_SCREEN_SCALE_FACTOR=0 orange-canvas --no-splash --no-welcome &      #add-on load crash fix

while :; do sleep 1; done