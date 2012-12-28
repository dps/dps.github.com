---
layout: post
title: "Raspberry Pi webcam; a gentle intro to crontab"
date: 2012-12-27 20:08
comments: true
categories: 
---
{% img alignright /static/images/webcam.jpg %}
Here's a quick and easy first project for new [Raspberry Pi](http://www.raspberrypi.org/) owners - turn your Pi into a webcam, and learn about Linux's ability to run repeated tasks at scheduled intervals with the `cron` utility.


These instructions work with [Adafruit's Occidentalis](http://learn.adafruit.com/adafruit-raspberry-pi-educational-linux-distro) distribution for Raspberry Pi.  They likely also work with any version of the Raspian distro, but I highly recommend Occidentalis if you'd like to do more hardware hacking with your Pi.  Adafruit have good [instructions on how to get started](http://learn.adafruit.com/adafruit-raspberry-pi-educational-linux-distro/occidentalis-v0-dot-2) and install on an sd card.

You will need to set up a wired or wireless internet connection to your Pi.

{% img alignright http://ws.assoc-amazon.com/widgets/q?_encoding=UTF8&Format=_SL110_&ASIN=B000RZQZM0&MarketPlace=US&ID=AsinImage&WS=1&tag=creativeflurr-20&ServiceVersion=20070822 Logitech Pro 9000 %}
## Choose a webcam
If you have a USB webcam lying around the house it's very likely that it will work just fine.  If not, I used the <a href="http://www.amazon.com/gp/product/B000RZQZM0/ref=as_li_ss_tl?ie=UTF8&tag=creativeflurr-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=B000RZQZM0">Logitech Pro 9000</a><img src="http://www.assoc-amazon.com/e/ir?t=creativeflurr-20&l=as2&o=1&a=B000RZQZM0" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /> successfully and a [full compatibility list](http://www.ideasonboard.org/uvc/) is available to check before you buy one.

## Install fswebcam

`fswebcam` is a small and simple webcam app for *nix.  Install it by issuing the following command on your Pi
```
sudo apt-get install fswebcam
```
<!-- more -->

If all is well, you will see something like the following:
```
The following NEW packages will be installed:
  fswebcam
0 upgraded, 1 newly installed, 0 to remove and 135 not upgraded.
Need to get 44.2kB of archives.
After this operation, 139kB of additional disk space will be used.
Fetched 44.2kB in 0s (1,181kB/s)  
Selecting previously deselected package fswebcam.
Unpacking fswebcam (from .../fswebcam_20091224-1_i386.deb) ...
Processing triggers for man-db ...
Setting up fswebcam ...
```

Let's take a look at the help page for `fswebcam` (edited to some of the parameters we care about)
```
$ fswebcam --help
```
```
Usage: fswebcam [<options>] <filename> [[<options>] <filename> ... ]

 Options:

 -?, --help                   Display this help page and exit.
...
 -d, --device <name>          Sets the source to use.
 -r, --resolution <size>      Sets the capture resolution.
```

With the webcam plugged in, we can take a photo and save it to the file `webcam.jpg` by issuing the command:
```
$ fswebcam -r 960x720 -d /dev/video0 webcam.jpg
```
(960x720 is one of the higher supported resolutions of my camera, yours may differ.  `/dev/video0` is where my camera appears by default when I plug it in.)

Here's what my full resolution image looked like:

![960x720 image from my webcam, taken with the Pi](/static/images/webcam_960.jpg)

## A quick intro to `cron`

`fswebcam` has native support to keep taking photos repeatedly in a loop (check out `man fswebcam` and look for 'loop'), but this is a great opportunity to explore Unix's `cron` utility which is one of the simple but powerful unix tools that every hacker should have in his arsenal.  As explained in more detail on the [wikipedia page for cron](http://en.wikipedia.org/wiki/Cron), unix systems running `cron` periodically read a set of cron table files and take care of any tasks which have fallen due.  To edit the cron table we must use a command called `crontab`.

You can view the cron table for the current user by issuing the command `crontab -l` - if you haven't set one up already, this will show:
```
$ crontab -l
no crontab for pi
```
The table is empty.  But let's take a look at the output from the server machine which hosts this blog:
```
$ crontab -l
# m h  dom mon dow   command
25 6 * * * ./rotate-logs.sh
```

That's more interesting - the administrator of this machine has added an entry to run a script called `rotate-logs.sh`, but what do the other fields mean?  The first line of this crontab is a comment (comment lines start with #) which might help explain.  This comment is inserted by `crontab` when you first start editing the table.

Now you might be able to guess what the meaning of the numbers on the second row are?

They are values, separated by spaces which define when to run the specified command.

`m` = minute past the hour, `h` = hour of the day, `dom` = day of the month, `mon` = month [of the year] and `dow` = day of week.  `cron` expects to find these fields separated by spaces and with `*`(star) to mean "any value" so in our example
```
25 6 * * * ./rotate-logs.sh
```
`cron` will read the file and any time that the minute of the hour is 25 and the hour of the day is 6, on any day of the month etc. `./rotate-logs.sh` will be run.  As you have probably figured out, this has the effect of running the command once a day at 6:25am.

You now know how to set up `cron` to run tasks at specified times of the day.  Let's say we want to update our webcam image every 15 minutes.  Doing that neatly requires some advanced `cron` syntax.  In addition to setting individual minutes, hours etc we can also provide a list of values so
```
0,15,30,45 * * * * ./rotate-logs.sh
```
would cause the rotate-logs.sh script to be run every 15 mins.  That's still a little long winded, so how about:
```
*/15 * * * * ./rotate-logs.sh
```
The `*/15` means "every 15 minutes".  The syntax works for any of the fields, so we can have
```
* */2 * * * ./foo # every two hours
* * */5 * * ./foo # every five days
```
etc.

OK, now you know `cron`, let's bring it all back together and make our actual webcam take a photo every 15 minutes.

## Use cron to take an image repeatedly

Recall that we ran the command `fswebcam -r 960x720 -d /dev/video0 webcam.jpg` to take a photo from the webcam.  Let's set up the `pi` user's crontab to do that every 15 mins.

At the command line, type
```
$ crontab -e
```
You should see a message to note that a new table is being created and end up in an editor with a blank file containing only the comment
```
# m h  dom mon dow   command
```

Use your new-found `cron`-fu to add
```
*/15 * * * * fswebcam -r 960x720 -d /dev/video0 /home/pi/webcam.jpg
```

Here you'll note that I've added a fully qualified path for `/home/pi/webcam.jpg` - although `cron` runs tasks with the working directory as the user's home directory, it's good practice to use full path names in scripts where you may not be certain of the working directory context.

Now save the file (if your editor is the default `nano`, press control-X) and you'll see
```
$ crontab -e
crontab: installing new crontab
$
```

Viola!  Your webcam is now saving that file every 15 mins.  If you want to check it's working correctly at this point, try running `ls -l webcam.jpg` now and after a 15 min delay to check that the file's timestamp has updated:
```
$ ls -l webcam.jpg 
-rw-r--r-- 1 pi pi 348450 2012-12-18 02:00 webcam.jpg
```

You can also navigate to the URL [file:///home/pi/webcam.jpg](file:///home/pi/webcam.jpg) in the web browser on the Pi to view the image.

## Let the world see

A webcam which updates a file only you can see is not particularly useful, let's fix that!  You have a few options for serving your webcam images.

### raspberry pi webserver

You could simply run a webserver locally on the Pi:

```
$ cd
$ python -m SimpleHTTPServer &
Serving HTTP on 0.0.0.0 port 8000 ...
```

Will run a simple webserver in the pi user's home directory and other machines on your network should now be able to see your webcam by visiting [http://raspberrypi.local:8000/webcam.jpg](http://raspberrypi.local:8000/webcam.jpg).  Note: this link relies on the [Bonjour](http://en.wikipedia.org/wiki/Bonjour) support in the Occidentalis distro, you might have to type the Pi's IP address instead.

If you have a regular home internet connection, you will probably need to set up port forwarding on your router to make that webserver accessible to the outside world, rather than just your own home network, which is a bit of a drag (and instructions depend on your router, though there are a few [attempts at tutorials to be found](https://www.google.com/search?q=raspberry+pi+webserver+router+port+forwarding)), so let's look at how to use a webserver on the open internet.

### webserver with ssh/scp access

If you have access to a webserver (e.g. [linode](http://www.linode.com/) ) which allows you to connect via `ssh`, you can [set up passwordless ssh](http://osxdaily.com/2012/05/25/how-to-set-up-a-password-less-ssh-login/) and add `;scp webcam.jpg your-server:/path/to/web/content` to the end of your crontab command to have cron upload the resulting image to your server after every snapshot. e.g.

```
*/15 * * * * fswebcam -r 960x720 -d /dev/video0 /home/pi/webcam.jpg;scp /home/pi/webcam.jpg linode:/var/www
```

### Advanced: use github pages (free)

The set up is a little involved, but this option is free.  The wonderful source control hosting service [github](http://github.com) will host web content for you on their servers.  First, install `git` on your Raspberry Pi:
```
sudo apt-get install git
```

Then, if you don't have one, create an account with [github](http://github.com) and set up [shared ssh keys as described in this article](https://help.github.com/articles/generating-ssh-keys).  `pbcopy` may not work on the Pi, so when you get to that step do `cat ~/.ssh/id_rsa.pub` and copy the resulting output to the clipboard manually - you'll need to use the web browser on the pi itself to complete the following step, or transfer that file to the computer you are working on somehow.

Next, create a new github repository named `username.github.com` where username is the github username you just created (or your existing account).  Any files you push to this repository will automatically be served on http://username.github.com.  For the examples below, `flexobot` is my username - change it to your own.

Let's push the webcam image to github once to see how it all works.  On your Raspberry Pi, run the following commands:
```
$ cd
$ git clone git@github.com:flexobot/flexobot.github.com.git
```
replacing `flexobot` with your user name, of course.
You should see:
```
$ git clone git@github.com:flexobot/flexobot.github.com.git
Initialized empty Git repository in /home/pi/flexobot.github.com/.git/
remote: Counting objects: 3, done.
remote: Total 3 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (3/3), done.
```

Now run the following
```
$ cp webcam.jpg flexobot.github.com/
$ cd flexobot.github.com/
$ git add .
$ git commit -a -m `date +%s`
$ git push origin
```

Which copies the webcam image into the copy of the github repository on your Raspberry Pi, adds and commits the changed files and pushes them to github.  If things worked correctly, you'll see
```
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 320.74 KiB, done.
Total 3 (delta 0), reused 0 (delta 0)
To git@github.com:flexobot/flexobot.github.com.git
   a961da0..6909423  master -> master
```

And navigating to the url [http://flexobot.github.com/webcam.jpg](http://flexobot.github.com/webcam.jpg) will display your latest webcam image!  Note: github pages can take 15 mins or so to update on your first push, but it's faster after that.

Now, let's automate that procedure every 15 mins.  We could simply copy all those commands to the end of the `crontab` entry, but that's a little unwieldy, so let's write a shell script to package it all up.

{% include_code webcam.sh %}

Save this file as `webcam.sh` in `/home/pi` - note that it automates both steps of taking an image and pushing it to github.  You'll need to mark the file executable by the system.
```
$ chmod +x webcam.sh
```
Let's test it out manually to check it works:
```
$ ./webcam.sh
--- Opening /dev/video0...
[master 8347ca2] 1356652754
 1 files changed, 0 insertions(+), 0 deletions(-)
Counting objects: 5, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 323 bytes, done.
Total 3 (delta 1), reused 0 (delta 0)
To git@github.com:flexobot/flexobot.github.com.git
   6909423..8347ca2  master -> master
```

Now we can simply update the crontab to run this script instead of `fswebcam`.

```
crontab -e
...
*/15 * * * * /home/pi/webcam.sh
```

Hurrah!  You've now learnt how to take photos with a USB webcam connected to a Raspberry Pi, some simple and advanced syntax for `cron` and `crontab` and how to push files to a webserver or github.



(Advanced) Exercise for the reader: it should also be possible to host your webcam image on [Dropbox](http://dropbox.com) by building their [linux daemon](https://www.dropbox.com/help/247/en) from source code for the Raspberry Pi (the binaries they provide are not suitable for the ARM processor on the Pi).  Please [drop me a note](mailto:davidsingleton at gmail.com) if you manage to do this successfully, I'll give it a try in the New Year.

Please leave any comments on [this Google Plus post](https://plus.google.com/u/0/117098976115661643090/posts/C2FUa7hU5XU).