import json
import rss
import deques
import strformat
import slack
import os
import httpclient

# todo: make this configurable
var datastore = %*{
    "xkcd": {
        "url": "https://xkcd.com/rss.xml",
        "channel": "#feeds",
    }, 
    "poorlydrawnlines": {
        "url": "http://feeds.feedburner.com/PoorlyDrawnLines?format=xml",
        "channel": "#feeds",
    },
    "spaceflightinsider": {
        "url": "https://www.spaceflightinsider.com/feed",
        "channel": "#feeds",
    }
}

type QueuedItem = object
    item: RSSItem
    channel: string
    feed: string

var unseenItems = initDeque[QueuedItem]()

proc checkFeed(key: string, feedInit: bool=false) =
    let feed = datastore[key]

    let feedUrl = feed["url"].getStr
    let channel = feed["channel"].getStr

    let verb = if feedInit: "init-ing" else: "checking"
    echo fmt"{verb} {key}: {feedUrl}"

    let data = getRSS(feedUrl)

    let lastSeen = feed{"lastSeenLink"}.getStr("")
    feed["lastSeenLink"] = %data.items[0].link
    if feedInit:
        return

    for item in data.items:
        if item.link == lastSeen:
            break
        echo fmt"adding {key} item to queue: {item.title}: {item.link}"
        unseenItems.addFirst(QueuedItem(
            item: item,
            channel: channel,
            feed: key,
        ))


proc emitUnseenItems*(client: HttpClient, delay:int=1000) =
    while unseenItems.len > 0:
        let qi = unseenItems.popFirst()
        let message = fmt"from {qi.feed}: {qi.item.title} {qi.item.guid}"
        echo client.SendSlackMessage(qi.channel, message)


proc CheckDefinedFeeds*(init=false) =
    for feed in datastore.keys:
        checkFeed(feed, feedInit=init)
    

if isMainModule:

    let client = NewSlackHttpClient()
    CheckDefinedFeeds(init=true)

    while true:
        CheckDefinedFeeds()
        client.emitUnseenItems()
        sleep(5*60*1000)


