---
layout: post
title: "Introducing PiUi: add a simple mobile phone UI to your RaspberryPi project."
date: 2013-03-20 18:57
comments: true
categories: 
---

<a href="http://github.com/dps/piui"><img src="https://raw.github.com/dps/piui/master/android/res/drawable-xhdpi/ic_launcher.png"/></a>

I'm excited to introduce you to a project I have been working on for a few weeks in my spare time: <b>[PiUi](http://github.com/dps/piui)</b>.


<iframe width="853" height="480" src="http://www.youtube.com/embed/2ay0vuW6aNY?rel=0" frameborder="0" allowfullscreen></iframe>


A lot of folks asked how to use my [RPi Timelapse Controller](http://blog.davidsingleton.org/raspberry-pi-timelapse-controller/) without the LCD Plate - which is kindof expensive and not everyone is comfortable to solder one up themselves.  The answer of course is that this is possible, but...  without a UI you are limited to having the controller run on boot and it's difficult to know everything's working correctly and/or take control when you know better.


The same is true of many hardware projects and an HDMI monitor + keyboard is not a feasible method of interaction away from your desk - wouldn't it be great if you could add a UI on a device you already have in your pocket to any Raspberry Pi project?


PiUi makes it easy to implement a rich mobile UI directly in python code and access it from your Android or iPhone.  It's powered by [ratchet.js](http://maker.github.com/ratchet/) so there are lots of UI components available to create beautiful interfaces.


All you need in addition to a Raspberry Pi is a wifi adaptor (like [this one](https://www.adafruit.com/products/814) from Adafruit).  Your Pi will create a wifi access point to connect your phone to, then simply navigate to <b>http://piui/</b> in a browser to access your app's UI.  There's even an [Android app](https://play.google.com/store/apps/details?id=org.davidsingleton.piui) to make connecting easy and show useful status info plus an iPhone webapp you can save to your homescreen.


Once the access point is set up (easy with pre-prepared [sd card images](https://github.com/dps/piui-sdcards)), the full code required for a python helloworld example is:

Install
-------
```
sudo pip install piui
```
HelloWorld
----------
<script src="https://gist.github.com/dps/5210265.js"></script>
Result
------
<img src="/images/helloworld.png" />

PiUi is open source - [fork it on github](http://www.github.com/dps/piui) - and is just getting started, so please use it, let me know what you think and help improve it.

For detailed setup instructions, read on.

Here's a little demo of the Timelapse project with a PiUi interface (source at [github.com/dps/piui-timelapse](http://github.com/dps/piui-timelapse))
<iframe width="420" height="315" src="http://www.youtube.com/embed/85POjhakf4U?rel=0" frameborder="0" allowfullscreen></iframe>

<!-- more -->

Setup Instructions
==================

The easy way (using a pre-prepared SD card image)
-------------------------------------------------

Download the `piui_plus_examples.zip` file from [github.com/dps/piui-sdcards](https://github.com/dps/piui-sdcards/blob/master/piui_plus_examples.zip?raw=true).  Unzip it and you'll find a 4Gb sd card image named `piui_plus_examples.img`.  Write it to an SD card by following the [usual Raspberry Pi instructions](http://elinux.org/RPi_Easy_SD_Card_Setup).  At present, this image is based on Occidentalis 0.2.

Assuming you have the same wifi adapter I do, this will work out of the box.  If not, read the [Pi-Point](http://www.pi-point.co.uk/) docs to configure for your own hardware.

On first boot, you can sync the latest piui source with:
```
cd piui
git pull origin
```
and start the demo app with:
```
python piui_demo.py
```

Viola!  PiUi nirvana.



The do-it-yourself way
----------------------

Start with the latest release of [Raspbian](http://www.raspberrypi.org/downloads) or (better as it's ready for hardware projects) [Occidentalis](http://learn.adafruit.com/adafruit-raspberry-pi-educational-linux-distro/occidentalis-v0-dot-2).

Follow the [Pi-Point documentation](http://www.pi-point.co.uk/) to turn your Pi into a wifi access point.  Note that if you use the [Adafruit wifi adapter](https://www.adafruit.com/products/814), these instructions do not work in full as the `nl80211` driver does not support that device (which uses a Realtek chipset).  [This blog post](http://blog.sip2serve.com/post/38010690418/raspberry-pi-access-point-using-rtl8192cu) explains how to make it work - thanks Paul!

Add an entry to `/etc/hosts` mapping the DNS name `piui` to the address you configured for the Pi in the step above.  Assuming it's `192.168.1.1`, then you should add the following to `/etc/hosts`
```
192.168.1.1     piui
```

Install `nginx` - nginx is an HTTP server and reverse proxy, we use it to multiplex requests to your app and the `piui-supervisor`.

```
sudo apt-get install nginx
```

Configure nginx using the [config file](https://github.com/dps/piui/blob/master/nginx-conf/nginx.conf) in the PiUi github repo - copy this to `/etc/nginx/nginx.conf` and restart nginx.
```
sudo /etc/init.d/nginx restart
```

Get the piui source code from github
```
cd /home/pi
git clone https://github.com/dps/piui.git
```

Arrange for the `piui-supervisor` to run on boot.
```
sudo cp /home/pi/piui/supervisor/piui-supervisor /etc/init.d
sudo update-rc.d piui-supervisor defaults
```

Done!  Run the demo app:
```
cd piui
python piui_demo.py
```

Connect your phone to the wifi AP and navigate to 'http://piui/'.


Questions, ideas?  [Join the discussion on Hacker News](https://news.ycombinator.com/item?id=5432615)