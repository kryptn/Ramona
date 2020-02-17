import os
import httpclient
import json
import strformat

proc sendMessage(client: HttpClient, channel, message: string): JsonNode =
    let apiUrl = "https://slack.com/api/chat.postMessage"

    let body = %*{
        "channel": channel,
        "text": message,
    }

    let response = client.post(apiUrl, $body)

    let data = response.body.parseJson()
    return data

proc newSlackHttpClient(): HttpClient =
    result = newHttpClient()

    let token = getEnv("SLACK_TOKEN")
    result.headers = newHttpHeaders({
        "Authorization": fmt"Bearer {token}",
        "Content-Type": "application/json",
    })


proc SendMessage*(channel, message: string): JsonNode =
    let client = newSlackHttpClient()
    let respData = client.sendMessage(channel, message)

    return respData


if isMainModule:
    let client = newSlackHttpClient()
    echo client.sendMessage("#bot-test", "hi")
