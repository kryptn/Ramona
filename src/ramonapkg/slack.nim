import os
import httpclient
import json
import strformat
import logging

proc sendMessage(client: HttpClient, channel, message: string): JsonNode =
    let apiUrl = "https://slack.com/api/chat.postMessage"

    let body = %*{
        "channel": channel,
        "text": message,
    }

    let response = client.post(apiUrl, $body)

    let data = response.body.parseJson()

    let lvl = if data["ok"].getBool(false): lvlInfo else: lvlWarn
    log(lvl, fmt"sent slack message, result: {$data}")

    return data

proc NewSlackHttpClient*(): HttpClient =
    result = newHttpClient()

    let token = getEnv("SLACK_TOKEN")
    result.headers = newHttpHeaders({
        "Authorization": fmt"Bearer {token}",
        "Content-Type": "application/json; charset=utf-8",
    })

    debug("created authenticated slack client")



template withSlackClient*(body: untyped) =
    let client {.inject.} = NewSlackHttpClient()
    defer: client.close()
    body    

proc SendSlackMessage*(client: HttpClient, channel, message: string): JsonNode =
    client.sendMessage(channel, message)

proc SendSlackMessage*(channel, message: string): JsonNode =
    withSlackClient:
        return client.SendSlackMessage(channel, message)


proc Emit*(client: HttpClient): proc(channel, message: string) =
    result = proc(channel, message: string) =
        discard client.SendSlackMessage(channel, message)


when isMainModule:
    var consoleLogger = newConsoleLogger(fmtStr="[$time] - $app - $levelname: ")
    addHandler(consoleLogger)

    echo SendSlackMessage("#bot-test", "hi")
