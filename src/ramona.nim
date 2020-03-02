import os
import logging
import strformat

import ramonapkg/feed
import ramonapkg/slacklogger

let fmtStr = "[$datetime] - $appname - $levelname: "

addHandler newConsoleLogger(lvlInfo, fmtStr=fmtStr)
addHandler newSlackLogger("#bot-test", lvlNotice, fmtStr=fmtStr)

const commit {.strdefine.} = "Unknown"

when isMainModule:

  notice(fmt"starting ramona, hello.{'\n'}{'\n'}commit {commit}")

  let configUrl = os.getEnv("RAMONA_CONFIG_URL").string
  var feeds = FeedsFromConfigUrl(configUrl)
  feeds.init()

  notice("I've just initialized, starting loop")

  while true:
    feeds.update()
    sleep(10*60*1000)
