import os

import ramonapkg/slack
import ramonapkg/feed

when isMainModule:
  let slackClient = NewSlackHttpClient()
  CheckDefinedFeeds(init=true)

  while true:
    CheckDefinedFeeds()
    slackClient.emitUnseenItems()
    sleep(5*60*1000)
