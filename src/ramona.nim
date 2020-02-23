import os
import logging

import ramonapkg/slack
import ramonapkg/feed

var consoleLogger = newConsoleLogger(fmtStr="[$datetime] - $appname - $levelname: ")
addHandler(consoleLogger)

when isMainModule:

  log(lvlInfo, "starting ramona, hello")
  let slackClient = NewSlackHttpClient()

  let configUrl = os.getEnv("RAMONA_CONFIG_URL").string
  var feeds = FeedsFromConfigUrl(configUrl)

  feeds.init()
  discard slackClient.SendSlackMessage("#bot-test", "I've just initialized, starting loop")

  while true:
    feeds.update(slackClient.Emit)
    sleep(5*60*1000)
