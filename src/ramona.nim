import os
import logging

import ramonapkg/feed
import ramonapkg/slacklogger

let fmtStr = "[$datetime] - $appname - $levelname: "

addHandler newConsoleLogger(lvlInfo, fmtStr=fmtStr)
addHandler newSlackLogger("#bot-test", lvlNotice, fmtStr=fmtStr)

when isMainModule:

  notice("starting ramona, hello")

  let configUrl = os.getEnv("RAMONA_CONFIG_URL").string
  var feeds = FeedsFromConfigUrl(configUrl)
  feeds.init()

  notice("I've just initialized, starting loop")

  while true:
    feeds.update()
    sleep(10*60*1000)
