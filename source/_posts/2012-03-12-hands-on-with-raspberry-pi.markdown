---
layout: post
title: !binary |-
  SGFuZHMgb24gd2l0aCBSYXNwYmVycnkgUGk=
wordpress_id: 72
wordpress_url: !binary |-
  aHR0cDovL2Jsb2cuZGF2aWRzaW5nbGV0b24ub3JnLz9wPTcy
date: 2012-03-12 23:27:31.000000000 +00:00
---
I was extremely fortunate to get access to a <a href="http://www.raspberrypi.org/" target="_blank">Raspberry Pi</a> alpha board for the past couple of weeks. For those of you who haven't already heard about it, the Raspberry Pi project was started to provide a tiny computer for kids to learn to program. It's a credit card sized computer with a 700 MHz ARM 11 CPU, 256 MB RAM, USB ports to connect a keyboard and mouse and HDMI out so you can plug it in to a TV or monitor - that's enough power to run Linux, a web browser etc. What's truly revolutionary is the price point - all of this comes for $25. At that price, the potential for a full blown computer in lots of homebrew embedded electronics projects could be transformational and the initial release of board for pre-order sold out in a matter of hours.

<img class="aligncenter" src="http://blog.davidsingleton.org/wp-content/uploads/2012/03/rpi.png" alt="rpi" />

So, what's it like in practice? I had a chance to play with the <a href="http://downloads.raspberrypi.org/images/debian/6/debian6-17-02-2012/debian6-17-02-2012.zip" target="_blank">Debian "squeeze"</a> distribution - the official Fedora based image was not yet available. Getting the image written onto an SD card (I recommend 4 GB min as the default image leaves not a lot of empty space to install new software on a 2 GB card) was simple enough following <a href="http://elinux.org/RPi_Easy_SD_Card_Setup" target="_blank">these instructions</a>. I decided that it would be fun to try to get my <a href="http://blog.davidsingleton.org/nnrccar" target="_blank">Neural Network controlled RC car</a> working on Raspberry Pi. The Rasp Pi team are working on an add on "<a href="http://www.raspberrypi.org/archives/411" target="_blank">Gertboard</a>" for I/O but since those aren't available yet and the device already has USB ports, connecting an Arduino UNO board should work great, right? Well, yes, but the debian image doesn't come with kernel driver support or prebuilt modules for the usb/serial interface Arduino uses. It took quite a bit of digging to find all the info I needed to build these myself, but I've made prebuilt modules available at the end of this post if you'd like to repeat this yourself.

This also means that Rasp Pi can be a great development environment for anyone getting started with Arduino who doesn't have an expensive PC to connect it to (e.g. at school).

Next step was to get the Rasp Pi driving the car. After installing the default Java JVM (open jdk), I got the camera streaming to the board - the screen shot you can see here is live video from an android phone for the self-driving car... woo!

<img src="http://blog.davidsingleton.org/wp-content/uploads/2012/03/IMG_20120304_232938.jpg"/>

Unfortunately, openjdk does not do JIT (just in time compilation) on ARM, so the performance of this set up was not going to get fast enough to drive the car (it managed about 1 frame per second without the neural network running). This was just the inspiration I needed to re-implement the project in C++! So, after a few further evenings' work I was able to claim what I think is the world's first self driving (RC) car powered by Raspberry Pi! The new C++ code can be found at <a href="https://github.com/dps/nnrccar/tree/master/cpp-driver">github.com/dps/nnrccar/tree/master/cpp-driver</a>.

Overall impressions? Rasp Pi is not going to let the throng of enthusiasts awaiting delivery down - it's enchanting to have a self contained fully fledged linux box and I know I'd have saved my pocket money to buy one when I was a kid. The Debian image had by no means a non-techy friendly setup process, but <a href="http://www.bbc.co.uk/news/technology-17190918">Eben has been very clear</a> that the software is expected to get much better now that the initial batch are being unleashed on an army of motivated geeks, and what I've read about the official Fedora Remix image so far sounds like it's a big step in the right direction.

I hope some of you also have fun with Arduino on this platform:

<strong>Arduino on Rasp Pi</strong>

Install the Arduino software
<code>sudo apt-get install arduino</code>

Download the pre-built <a href="http://blog.davidsingleton.org/static/rpi_kernel_modules.zip">rasp pi / debian kernel modules</a> I built.

Enable the modules
<pre>
sudo insmod drivers/usb/class/cdc-acm
sudo insmod drivers/usb/serial/usbserial
sudo insmod drivers/usb/serial/ftdi_sio
</pre>

Plug in your Arduino UNO.

You should now have a USB serial port for the board on <code>/dev/ttyACMO</code>. Enjoy!
