#!/bin/bash
GITUSER="flexobot"

fswebcam -r 960x720 -d /dev/video0 /home/pi/webcam.jpg
cp /home/pi/webcam.jpg /home/pi/$GITUSER.github.com/
cd /home/pi/$GITUSER.github.com/
git add .
git commit -a -m `date +%s`
git push origin