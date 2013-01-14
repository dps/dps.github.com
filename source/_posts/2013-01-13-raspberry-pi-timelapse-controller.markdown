---
layout: post
title: "Raspberry Pi Timelapse Controller"
date: 2013-01-13 17:10
comments: true
categories: 
---

<div>
    <span>
<img src="/images/timelapse_setup.jpg" alt="" title="" width="480px"/>
</span><span>
<iframe width="480" height="360" src="http://www.youtube.com/embed/AZbK4acS5Mc" frameborder="0" allowfullscreen></iframe></span>
</div>

A few weeks ago, I found <a href="http://www.youtube.com/watch?v=Zg_iO34_65k">this beautiful video on Youtube</a> -- a timelapse video of stars and the Milky Way.  Seeing the stars appear to rotate overhead (due to the rotation of the Earth) and the intricate structure of our own galaxy gave me a profound feeling of the scale of the universe that we move through on spaceship Earth.  Of course, I wanted to record my own Milky Way timelapse.

Capturing the Milky Way requires dark skies and long exposures, so this seemed like a great project to build using my fairly old <a href="http://www.amazon.com/gp/product/B0007QKN22/ref=as_li_ss_tl?ie=UTF8&tag=creativeflurr-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=B0007QKN22">Canon EOS 350D</a> and <a href="http://www.raspberrypi.org/">Raspberry Pi</a>.  I also spent some time exploring what existing timelapse controllers can do - the holy grail of timelapse is to be able to capture sunset (and sunrise) seamlessly, where a wide range of shutter speeds need to be used to capture an appealing scene as the ambient light levels change profoundly.  You can see at the end of the milky way video I linked above that sunrise is not handled so well!  There are a number of scripts which can be run in-camera with homebrew firmware (e.g. <a href="http://chdk.wikia.com/wiki/CHDK">chdk</a>) but these cannot choose the best shutter speed based on the images taken - they have to guess the best values once there is too little light for the camera lightmeter to judge.  Since we can run fully featured image processing software like ImageMagick on the Linux based Pi, I decided to build a controller which could capture sunset.

I also recently got hold of an <a href="http://www.adafruit.com/products/1110">Adafruit LCD Plate</a> for my Pi so I've added a User Interface too.

I haven't yet been able to make the Milky Way timelapse which is my end goal, but hope to do so in the coming weeks next time it's dark, clear and I'm at Lake Tahoe, but the controller is working nicely.

Read on to find full instructions, some demo videos and the software so you can try it yourself.

At the top of this post you can see the set up and a demo video.

<!-- more -->

The hardware
------------

The hardware set up is very simple - I'm using a Raspberry Pi connected to a Canon EOS 350D via the camera's regular USB interface.  The Raspberry Pi is powered from an external battery pack - I'm using a huge capacity <a href="http://www.amazon.com/gp/product/B009USAJCC/ref=as_li_ss_tl?ie=UTF8&tag=creativeflurr-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=B009USAJCC">Anker 10000mAh pack</a> which I'd recommend but there are many other options.  The camera will need to be on a tripod - any tripod will work.

The Software
------------

The timelapse controller is written in Python and makes use of two great Linux packages which need to be installed on the Pi - `gphoto2` for controlling the camera and downloading images and `ImageMagick` for analysing the resulting images to adjust exposure in the next frame.  The python software is available at <a href="https://github.com/dps/rpi-timelapse">github.com/dps/rpi-timelapse</a>.

To install the dependencies:

```
$ sudo apt-get install gphoto2
$ sudo apt-get install imagemagick
$ sudo apt-get install git
```

And to fetch the python code:
```
git clone https://github.com/dps/rpi-timelapse.git
```

You can now run the timelapse controller with
```
cd rpi-timelapse
python tl.py
```

When it starts, it first shows the network connection status and IP address if connected to a network which makes it easy to connect to the Pi without a display connected.  After tapping select, it shows the starting shutter speed and ISO that will be used.
```
Timelapse
T: 1/50 ISO: 200
```
You can tap UP/DOWN to shorten/lengthen the inital exposure, and SELECT will start the timelapse.

<center><img src="/images/timelapse-ui.png" alt="" title="" width="640px"/></center><br/>

While shooting a timelapse sequence, a photo will be taken every 30 seconds (change `MIN_INTER_SHOT_DELAY_SECONDS` if you'd like to vary).  Each photo will be downloaded to the pi and the `identify` tool from ImageMagick is used to determine the average brightness of the image.  If the brightness is below `MIN_BRIGHTNESS`, the controller extends the shutter time to make the next exposure incrementally brighter and vice versa if the image is too bright.  This should result in a sequence which is reasonably exposed as the light level rises at sunrise or falls at sunset.  All the shutter / ISO settings which will actually be used are defined in the `CONFIGS` array in `tl.py` which can be edited for your camera.

```
CONFIGS = [("1/1600", 200),
           ("1/1000", 200),
           ("1/800", 200),
         ...
           ("1/50", 200),
           ("1/40", 200),
           ("1/30", 200),
           ("1/20", 200),
         ...        
           ("30", 200),
           ("30", 400),
           ("30", 800),
           ("30", 1600)]
```

I have elected only to raise the ISO sensitivity once the longest shutter time has been reached (since higher ISO equals more noise), but you could equally vary ISO throughout the sequence if desired.

When the timelapse is done, all the resulting images can be copied off the pi to a computer connected to the same network with:

```
scp pi@raspberrypi.local:rpi-timelapse/*.JPG .
```

And once downloaded, stitched into a nice timelapse video using `FFmpeg`:

```
ffmpeg -r 18 -q:v 2 -start_number XXXX -i /tmp/timelapse/IMG_%d.JPG output.mp4
```

The change of exposure time at sunset ensures that each individual image is reasonably exposed, but when stitching them into a movie, this results in a little flicker each time the shutter time is ramped up.  This can easily be adjusted for by running the following before `ffmpeg`:

```
for a in *; do echo $a;/opt/ImageMagick/bin/mogrify -auto-gamma $a;done
```


Alternative Cameras
-------------------

This set up uses the Linux `gphoto2` package to control the camera.  Any other camera which supports long enough exposures and is supported by `gphoto2` should work, but you might need to make a few tweaks to the `CONFIGS` in `tl.py` to use shutter speeds and ISO modes supported by your camera.

Start on boot
-------------

You can make tl.py run on boot (instructions in this <a href="https://github.com/dps/rpi-timelapse/blob/master/README.md">README</a>) so that you can take the camera and raspberry pi out without a computer to kick off the timelapse.

Notes / work in progress
------------------------

The camera battery only lasted for around 90 30 second exposures when I tested it this weekend (stars video below), though the temperature was below 0 F.  I will try again with an extended battery grip in future.  You can see a couple of my test shots below, neither is particularly photogenic, I was just testing the setup rather than trying to get a great video (yet!), expect to see some updates with video when I get a chance.

<iframe width="420" height="315" src="http://www.youtube.com/embed/L1ZXyQefgy0?rel=0" frameborder="0" allowfullscreen></iframe>
<iframe width="420" height="315" src="http://www.youtube.com/embed/n8DVoZvtql4?rel=0" frameborder="0" allowfullscreen></iframe>

Comments
--------

I'm keen to know what you think or if you try it yourself - Please <a href="https://plus.google.com/117098976115661643090/posts/dquzNka5n3a">comment on this Google+ post</a>.
