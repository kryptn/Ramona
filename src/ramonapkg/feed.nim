import json
import rss
import strformat
import httpclient

import logging
import sets
import sequtils

import slack

type
    Feed = ref object of RootObj
        name: string
        url: string
        channel: string
        items: HashSet[string]
    

proc NewFeed*(feedName, feedUrl, slackChannel: string): Feed =
    info(fmt"creating new feed [name: {feedName}, channel: {slackChannel}]")
    result = Feed(name: feedName, url: feedUrl, channel: slackChannel)

proc feedsFromConfig(config: JsonNode): seq[Feed] =
    proc feedFromIt(node: JsonNode): Feed =
        let name = node["name"].getStr
        let url = node["url"].getStr
        let channel = node["channel"].getStr
        NewFeed(name, url, channel)
    
    config.getElems.mapIt(feedFromIt(it))

proc FeedsFromConfigUrl*(url: string): seq[Feed] =
    let client = newHttpClient()
    defer: client.close()

    let config = client.getContent(url).parseJson
    return feedsFromConfig(config)

proc FeedsFromConfigFile*(filename: string): seq[Feed] =
    let config = readFile(filename).parseJson
    return feedsFromConfig(config)


proc getFeedItems(feed: Feed): seq[RSSItem] =
    result = @[]
    debug(fmt"getting feed items [name: {feed.name}, channel: {feed.channel}]")

    try:
        result = getRSS(feed.url).items
    except:
        let
            e = getCurrentException()
            msg = getCurrentExceptionMsg()
        let errorMsg = fmt"got exception in feed{'\n'}{'\n'}[name: {feed.name}, channel: {feed.channel}]{'\n'}{'\n'}{msg}{'\n'}{'\n'}{repr(e)}"
        error(errorMsg)


proc setItems(feed: Feed, feedItems: seq[RSSItem]) =
    feed.items = feedItems.mapIt(it.link).toHashSet()

proc updatedItems(feed: Feed, feedItems: seq[RSSItem]): seq[RssItem] =
    result = feedItems.filterIt(feed.items.contains(it.link) == false)

proc init*(feed: Feed) =
    info(fmt"initializing feed items [name: {feed.name}, channel: {feed.channel}]")
    let feedItems = feed.getFeedItems()
    feed.setItems(feedItems)

proc init*(feeds: seq[Feed]) =
    info("initializing all feeds")
    for feed in feeds.items:
      feed.init()


proc update*(feed: Feed, emit: proc(channel, message: string)) =
    let feedItems = feed.getFeedItems()
    
    let updatedItems = feed.updatedItems(feedItems)
    debug(fmt"got {updatedItems.len} new feed items [name: {feed.name}, channel: {feed.channel}]")

    for item in feed.updatedItems(feedItems).items:
        info(fmt"emitting update [name: {feed.name}, channel: {feed.channel}, title: {item.title}, link: {item.link}]")
        let message = fmt"from {feed.name}: {item.title} {item.guid}"
        emit(feed.channel, message)

    feed.setItems(feedItems)

proc update*(feeds: seq[Feed]) =
    info("updating feeds")

    withSlackClient:
        for feed in feeds.items:
            feed.update(client.Emit)


when isMainModule:
    import slack

    var consoleLogger = newConsoleLogger(fmtStr="[$time] - $app - $levelname: ")
    addHandler(consoleLogger)

    let client = NewSlackHttpClient()

    let feeds = FeedsFromConfigUrl("https://gist.githubusercontent.com/kryptn/b3f1090d752b6941d8d8be350e8c7c5e/raw/9a67280125716e50c2ade8efa2a40d93d7365d53/ramona_config.json")

    for feed in feeds.items:
        feed.update(client.Emit)

    client.close()