import logging
import slack
import strformat

type SlackLogger* = ref object of Logger
    channel: string

method log*(logger: SlackLogger, level: Level, args: varargs[string, `$`]) =
    let ln = substituteLog(logger.fmtStr, level, args)
    withSlackClient:
        discard client.SendSlackMessage(logger.channel, fmt"```{ln}```")

proc newSlackLogger*(channel: string, levelThreshold = lvlAll, fmtStr = defaultFmtStr): SlackLogger = 
    new result
    result.levelThreshold = levelThreshold
    result.fmtStr = fmtStr
    result.channel = channel