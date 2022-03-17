#!/bin/bash

geometry=$1
width=${geometry%x*}
height=${geometry#*x}
frequency=$(( $width * $height * 60 / 1000000 ))
xrandr --newmode $geometry $frequency $width 0 0 $width $height 0 0 $height
xrandr --addmode VNC-0 $geometry