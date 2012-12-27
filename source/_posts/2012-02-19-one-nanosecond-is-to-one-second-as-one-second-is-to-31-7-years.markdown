---
layout: post
title: !binary |-
  T25lIG5hbm9zZWNvbmQgaXMgdG8gb25lIHNlY29uZCBhcyBvbmUgc2Vjb25k
  IGlzIHRvIDMxLjcgeWVhcnM=
wordpress_id: 61
wordpress_url: !binary |-
  aHR0cDovL2Jsb2cuZGF2aWRzaW5nbGV0b24ub3JnLz9wPTYx
date: 2012-02-19 17:45:06.000000000 +00:00
---
<a href="http://www.flickr.com/photos/mrlins/6151504947/" title="Drops on green #1 by mrlins, on Flickr"><img src="http://farm7.staticflickr.com/6184/6151504947_d9670df924.jpg" width="500" height="354" alt="Drops on green #1"></a>

<a href="https://plus.google.com/u/0/112493031290529814667/posts" target="_blank">Peter Burns</a> wrote a <a href="http://goo.gl/z4skG" target="_blank">great post</a> earlier last week about timescales as they might be "perceived" by a computer's CPU... "your CPU lives by the nanosecond" [and humans live by the second].  The post seems to be loosely based on <a href="http://goo.gl/PaeGt" target="_blank">this article</a>.

I found that the comparison really resonated with me and could provide a useful way to get an intuitive handle on the tradeoffs we make when designing software systems...

A nano-second is one billionth of a second.

Moderately fast modern CPUs can process a few instructions (e.g. comparing a couple of numbers) every nanosecond, much as humans can "process" a few basic facts every second (e.g. comparing a couple of numbers!).  This might blow your mind:  A nanosecond is to one second as one second is to 31.7 years!

Peter's comparisons talked only about the timescales it takes to shuffle data backwards and forwards within one computer (CPU, main memory, disk).  Many software systems nowadays consist of a collection of computers connected together by a fast network (within a datacenter) and often co-operating with services running on the other side of the globe to deliver the kinds of applications and services we're used to using on the web.  Therefore, I thought it quite interesting to extend the analogy and think about some of the <a href="http://goo.gl/0KpSu" target="_blank">Numbers Everyone Should Know</a> (due to Jeff Dean) as if a nanosecond was a second.

<strong>L1 cache reference</strong> - 0.5 ns  -> <strong>half a second</strong>.<br/>
<strong>Branch mispredict</strong> - 5 ns -> <strong>5 seconds</strong>.<br/>
<strong>L2 cache reference</strong> - 7 ns -> <strong>7 seconds</strong>.<br/>
<strong>Main memory reference</strong> - 100 ns -> <strong>1 minute 40 seconds</strong>.<br/>

Now it gets interesting:<br/>

<strong>Send 2K bytes over 1 Gbps network</strong> - 20,000 ns -> <strong>5 and a half hours</strong>.<br/>
<strong>Read 1 MB sequentially from memory</strong> - 250,000 ns -> <strong>nearly 3 days</strong>.<br/>
<strong>Round trip within same datacenter</strong>  - 500,000 ns -> <strong>nearly 6 days</strong>.<br/>
<strong>Disk seek</strong> - 10,000,000 ns -> <strong>4 months</strong><br/>
<strong>Read 1 MB sequentially from disk</strong> - 20,000,000 ns -> <strong>8 months</strong>.<br/>
<strong>Send packet California->Europe->California</strong> - 150,000,000 ns -> <strong>4.75 years</strong>.<br/>

The most significant (and perhaps initially unintuitive) of these is that it can be significantly faster to read data from RAM on another nearby machine via the network (6 days) rather than seek to it on local disk (8 months).

I'll throw one more in there:  <a href="http://goo.gl/jknNJ" target="_blank">round trip across a 3G mobile network</a>: 250,000,000 ns -> <strong>nearly 8 years</strong>!

What's the point of thinking like this?  Well, by putting timescales into units that humans can more intuitively understand and reason about, I hope this might help me (and you) make better choices as we design new systems.
