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

proc NewSlackHttpClient*(): HttpClient =
    result = newHttpClient()

    let token = getEnv("SLACK_TOKEN")
    result.headers = newHttpHeaders({
        "Authorization": fmt"Bearer {token}",
        "Content-Type": "application/json",
    })

proc SendSlackMessage*(client: HttpClient, channel, message: string): JsonNode =
    client.sendMessage(channel, message)

proc SendSlackMessage*(channel, message: string): JsonNode =
    let client = NewSlackHttpClient()
    return client.SendSlackMessage(channel, message)


if isMainModule:
    let client = NewSlackHttpClient()
    echo client.sendMessage("#bot-test", "hi")
