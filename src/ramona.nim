import os
import logging

import ramonapkg/slack
import ramonapkg/feed
import ramonapkg/slacklogger

var consoleLogger = newConsoleLogger(fmtStr="[$datetime] - $appname - $levelname: ")
var slackLogHandler = newSlackLogger("#bot-test", lvlNotice, fmtStr="[$datetime] - $appname - $levelname: ")
addHandler(consoleLogger)
addHandler(slackLogHandler)

when isMainModule:

  notice("starting ramona, hello")

  let configUrl = os.getEnv("RAMONA_CONFIG_URL").string
  var feeds = FeedsFromConfigUrl(configUrl)
  feeds.init()

  notice("I've just initialized, starting loop")

  while true:
    feeds.update()
    sleep(5*60*1000)
