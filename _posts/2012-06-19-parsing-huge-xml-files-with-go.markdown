---
layout: post
title: !binary |-
  UGFyc2luZyBodWdlIFhNTCBmaWxlcyB3aXRoIEdv
wordpress_id: 89
wordpress_url: !binary |-
  aHR0cDovL2Jsb2cuZGF2aWRzaW5nbGV0b24ub3JnLz9wPTg5
date: 2012-06-19 04:37:58.000000000 +01:00
---
I've recently been messing around with the <a href="http://en.wikipedia.org/wiki/Wikipedia:Database_download">XML dumps of Wikipedia</a>.  These are pretty huge XML files - for instance the most recent revision is 36G when uncompressed.  That's a lot of XML!  I've been experimenting with a few different languages and parsers for my task (which also happens to involve some non trivial processing for each article) and found <a href="http://www.golang.org/">Go</a> to be a great fit.

Go has a <a href="http://golang.org/pkg/encoding/xml/">common library package for parsing xml</a> (encoding/xml) which is very convenient to code against.  However, the simple version of the API requires parsing the whole document in one go, which for 36G is not a viable strategy.   The parser can also be used in a streaming mode but I found the documentation and examples online to be terse and non-existant respectively, so here is my example code for parsing wikipedia with <b>encoding/xml</b> and a little explanation!

(full example code at <a href="https://github.com/dps/go-xml-parse/blob/master/go-xml-parse.go">https://github.com/dps/go-xml-parse/blob/master/go-xml-parse.go</a>)

Here's a little snippet of an example wikipedia page in the doc:
<pre><span style=' color: Green;'>// &lt;page&gt;</span> 
<span style=' color: Green;'>//     &lt;title&gt;Apollo 11&lt;/title&gt;</span> 
<span style=' color: Green;'>//      &lt;redirect title="Foo bar" /&gt;</span> 
<span style=' color: Green;'>//     ...</span> 
<span style=' color: Green;'>//     &lt;revision&gt;</span> 
<span style=' color: Green;'>//     ...</span> 
<span style=' color: Green;'>//       &lt;text xml:space="preserve"&gt;</span> 
<span style=' color: Green;'>//       {{Infobox Space mission</span> 
<span style=' color: Green;'>//       |mission_name=&amp;lt;!--See above--&amp;gt;</span> 
<span style=' color: Green;'>//       |insignia=Apollo_11_insignia.png</span> 
<span style=' color: Green;'>//     ...</span> 
<span style=' color: Green;'>//       &lt;/text&gt;</span> 
<span style=' color: Green;'>//     &lt;/revision&gt;</span> 
<span style=' color: Green;'>// &lt;/page&gt;</span></pre>

In our Go code, we define a struct to match the &lt;page&gt; element, its nested &lt;redirect&gt; element and grab a couple of fields we're interested in (&lt;text&gt; and &lt;title&gt;).

<pre>type Redirect <span style="color: blue;">struct</span> { 
    Title <span style="color: blue;">string</span> `xml:<span style="color: maroon;">"title,attr"</span>` 
} 

type Page <span style="color: blue;">struct</span> { 
    Title <span style="color: blue;">string</span> `xml:<span style="color: maroon;">"title"</span>` 
    Redir Redirect `xml:<span style="color: maroon;">"redirect"</span>` 
    Text <span style="color: blue;">string</span> `xml:<span style="color: maroon;">"revision&gt;text"</span>` 
}</pre>

<p>Now we would usually tell the parser that a wikipedia dump contains a bunch of &lt;page&gt;s and try to read the whole thing, but let's see how we stream it instead.</p>  It's quite simple when you know how - iterate over tokens in the file until you encounter a StartElement with the name "page" and then use the magic <code>decoder.DecodeElement</code> API to unmarshal the whole following page into an object of the Page type defined above.  Cool!

<pre>decoder := xml.NewDecoder(xmlFile) 

<span style=' color: Blue;'>for</span> { 
    <span style=' color: Green;'>// Read tokens from the XML document in a stream.</span> 
    t, _ := decoder.Token() 
    <span style=' color: Blue;'>if</span> t == nil { 
        <span style=' color: Blue;'>break</span> 
    } 
    <span style=' color: Green;'>// Inspect the type of the token just read.</span> 
    <span style=' color: Blue;'>switch</span> se := t.(type) { 
    <span style=' color: Blue;'>case</span> xml.StartElement: 
        <span style=' color: Green;'>// If we just read a StartElement token</span> 
        <span style=' color: Green;'>// ...and its name is "page"</span> 
        <span style=' color: Blue;'>if</span> se.Name.Local == <span style=' color: Maroon;'>"page"</span> { 
            var p Page 
            <span style=' color: Green;'>// decode a whole chunk of following XML into the</span>
            <span style=' color: Green;'>// variable p which is a Page (se above)</span> 
            decoder.DecodeElement(&amp;p, &amp;se) 
            <span style=' color: Green;'>// Do some stuff with the page.</span> 
            p.Title = CanonicalizeTitle(p.Title)
            ...
        } 
...</pre>

I hope this saves you some time if you need to parse a huge XML file yourself.
