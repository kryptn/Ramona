import os

import ramonapkg/slack
import ramonapkg/feed

when isMainModule:
  let slackClient = NewSlackHttpClient()
  discard slackClient.SendSlackMessage("#bot-test", "Hello, I just started running")
  CheckDefinedFeeds(init=true)

  while true:
    CheckDefinedFeeds()
    slackClient.emitUnseenItems()
    sleep(5*60*1000)
