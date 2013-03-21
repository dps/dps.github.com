---
layout: post
title: "Raspberry Pi Website Hit Tracker"
date: 2013-02-04 21:49
comments: true
categories: 
---

You just made a funky neon sign flash in my living room.

How?  I have just completed my latest project which is a neon lamp which lights up every time someone visits my website.  It's controlled by a little relay board I built out on an <a href="http://adafruit.com/products/1148">Adafruit permaproto board</a> and connected to a <a href="http://gan.doubleclick.net/gan_click?lid=41000613802463368&pid=83-14421&adurl=http%3A%2F%2Fwww.mcmelectronics.com%2Fproduct%2F83-14421%26scode%3DGS401%26CAWELAID%3D1599056700&usg=AFHzDLsOgsCYMI_KRBudg9V-cbzxD_5s2Q&pubid=21000000000379947">Raspberry Pi</a>.  The Raspberry Pi is running a simple python script which generates an event every time someone loads this page.  I've made the part which integrates with the website open for anyone to use so you can build this out for yourself - have fun!

<div><span><img src="/static/relay.png"/></span><span><iframe width="560" height="315" src="http://www.youtube.com/embed/N1B0BHk9FL4?rel=0" frameborder="0" allowfullscreen></iframe></iframe></span></div>

Building the Relay Board
------------------------

The relay board connects to the Raspberry Pi General Purpose I/O (GPIO) pins via a ribbon cable.  Adafruit sells a <a href="http://gan.doubleclick.net/gan_click?lid=41000613802463368&pid=83-14389&adurl=http%3A%2F%2Fwww.mcmelectronics.com%2Fproduct%2F83-14389%26scode%3DGS401%26CAWELAID%3D1562166096&usg=AFHzDLv2-yk0flf9LYQoeR18YHLcWv3vvw&pubid=21000000000379947">Pi Cobbler</a> which makes it easy to break out the GPIO pins on a breadboard for prototyping.  Once you're happy that the prototype is working, transferring a breadboard layout to the <a href="http://adafruit.com/products/1148">permaproto</a> board is quite simple (the soldering is easy and you just copy what you had on the breadboard).

<img src="/static/circuit.png"/><br/>

Here is the circuit diagram for the relay board - we drive the relay coil from the 5V supply which is switched on and off using a transistor controlled by one of the digital out pins (I used pin 18).  The diode prevents reverse voltage as the relay switches off from damaging the Pi.

You can see step-by-step instructions on how to assemble the relay board on <a href="https://www.sharpenapp.com/spark/dps/raspberry-pi-relay-board-1">this spark</a>.<br/><center>
<a href="https://www.sharpenapp.com/spark/dps/raspberry-pi-relay-board-1"><img src="/static/spark.png" width="80%"/></a></center>
<h2><a href="https://www.sharpenapp.com/spark/dps/raspberry-pi-relay-board-1">Spark: Raspberry Pi relay board.</a></h2>
<!-- more -->

Connecting the lamp
-------------------

You can use any lamp or electronic device powered with a low direct current (anything which plugs in to a USB port or runs on batteries is ideal).  DO NOT attempt to use a mains powered lamp.  Even if your relays is rated for 110V, the prototyping board has exposed connections and mains electricity can kill.

Simply cut one side of the power cable and attach to the switched part of the relay (I used screw terminals so I can connect and disconnect as I please).

<img src="/static/proto.png" width=100%/>

RPi test program
----------------

The following little test program will drive your lamp on and off every 2 seconds to verify everything is working.

I used the Adafruit Occidentalis distribution of Linux.  You can also use Raspbian.  Follow <a href="http://learn.adafruit.com/adafruits-raspberry-pi-lesson-4-gpio-setup/configuring-gpio">these instructions</a> to get the Pi set up, or use the quickstart below:

```
sudo apt-get install python-rpi.gpio
```

Run the following Python program:
```
import RPi.GPIO as gpio
import time

gpio.setmode(gpio.BCM)
gpio.setup(18, gpio.OUT)
while True:
  time.sleep(2)
  gpio.output(18, True)
  print "True"
  time.sleep(2)
  gpio.output(18, False)
  print "False"
```

Each time False is printed, the lamp should turn on and off again when True is printed.

Set up your website
-------------------

This bit is easy.  Visit <a href="http://webalert.davidsingleton.org/">http://webalert.davidsingleton.org/</a>, register your web page(s) and follow the instructions to add code to your web page.

<center><a href="http://webalert.davidsingleton.org/"><img src="/static/webalert.png" style="border: 1px solid #ccc;"/></a></center>

What does webalert do?  It's a simple service hosted on Heroku which serves up a javascript script which adds a 1 pixel, transparent, image to your webpage with a unique URL.  When the visitor's web browser loads that image, the service sees the event and publishes a message to a Redis pubsub queue which the Raspberry Pi listens to.  You don't need to write or install this, you can simply reuse mine.


<center><a href="http://webalert.davidsingleton.org/"><img src="/static/waflow.png" style="border: 1px solid #ccc;"/></a></center>


Run the client on your Pi
-------------------------

The webalert client uses `redis` to subscribe to events generated each time your website is loaded.  First, install the redis python module:
```
sudo pip install redis
```

Then, in a new directory, get the webalert code:
```
git clone https://github.com/dps/webalert.git
```

And write a simple client which uses it - e.g.:
<script src="https://gist.github.com/dps/4712899.js"></script>

Finally, run passing your webalert client token on the command line:
```
sudo python weblight.py [your token]
```

Ta da!  clickety click flashy flash, your website in your living room.

Comments? Join the <a href="http://news.ycombinator.com/item?id=5176648">discussion</a> on Hacker News.

<br/><br/>
<hr/>
<br/>
Want to get started with RPi + electronics yourself?  Here's some stuff to buy (affiliates links, but the kits and prices are good).
<table><tr><td><center>
<a href="http://gan.doubleclick.net/gan_click?lid=41000613802463368&pid=83-14421&adurl=http%3A%2F%2Fwww.mcmelectronics.com%2Fproduct%2F83-14421%26scode%3DGS401%26CAWELAID%3D1599056700&usg=AFHzDLsOgsCYMI_KRBudg9V-cbzxD_5s2Q&pubid=21000000000379947">
<b>512MB Raspberry Pi Project Board Model B</b>
<br/>
<img src="http://www.mcmelectronics.com/content/productimages/s4/83-14421.jpg" width="240px"/></a></center></td><td>&nbsp;</td><td><center>

<a href="http://gan.doubleclick.net/gan_click?lid=41000613802463368&pid=83-14385&adurl=http%3A%2F%2Fwww.mcmelectronics.com%2Fproduct%2F83-14385%26scode%3DGS401%26CAWELAID%3D1562166092&usg=AFHzDLtTF5zhVmSUuM4la4iPzMpIsTHYlg&pubid=21000000000379947">
<img src="http://www.mcmelectronics.com/content/productimages/s4/83-14385.jpg" width="240px"/>
<br/>
<b>Adafruit 955 Raspberry Pi (Electronics) Starter Project Kit</b>
</a></center></td></tr></table>