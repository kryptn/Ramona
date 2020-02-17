import json
import rss
import deques
import strformat
import slack
import os

var datastore = %*{
    "xkcd": {
        "url": "https://xkcd.com/rss.xml",
        "lastSeenLink": "",
    }, 
    "poorlydrawnlines": {
        "url": "http://feeds.feedburner.com/PoorlyDrawnLines?format=xml",
        "lastSeenLink": "",
    },
    "spaceflightinsider": {
        "url": "https://www.spaceflightinsider.com/feed",
        "lastSeenLink": "",
    }
}

var unseenItems = initDeque[RSSItem]()

proc checkFeed(key: string, feedInit: bool=false) =
    let lastSeen = datastore[key]["lastSeenLink"].getStr

    let feedUrl = datastore[key]["url"].getStr
    echo fmt"checking {key}: {feedUrl}"

    let data = getRSS(feedUrl)

    datastore[key]["lastSeenLink"] = %data.items[0].link
    if feedInit:
        return

    let endi = min(data.items.len, 4)
    for item in data.items[0..<endi]:
        if item.link == lastSeen:
            break
        echo fmt"adding to queue: {item.title}: {item.link}"
        unseenItems.addFirst(item)


proc consumeUnseenItems(delay: int) =
    while unseenItems.len > 0:
        let item = unseenItems.popFirst()
        let message = fmt"{item.title} {item.guid}"
        echo SendMessage("#bot-test", message) 

        sleep(delay)

if isMainModule:

    for feed in datastore.keys:
        checkFeed(feed, feedInit=true)


    while true:
        for feed in datastore.keys:
            checkFeed(feed)
            consumeUnseenItems(1000)
        sleep(5*60*1000)


