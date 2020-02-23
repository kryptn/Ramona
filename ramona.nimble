# Package

version       = "0.1.0"
author        = "kryptn"
description   = "A personal notifier"
license       = "MIT"
srcDir        = "src"
bin           = @["ramona"]
binDir        = "bin"

# Dependencies

requires "nim >= 1.0.6"
requires "rss >= 1.1"

task trySlack, "try slack":
  exec "nim c -r -d:ssl --out:bin/trys/slack src/ramonapkg/slack.nim"

task tryFeed, "try feed":
  exec "nim c -r -d:ssl --out:bin/trys/feed src/ramonapkg/feed.nim"

task test, "run tests":
  exec "nim c -r --out:bin/tests/test_feed tests/pkg/test_feed.nim"
  exec "nim c -r --out:bin/tests/test_slack tests/pkg/test_slack.nim"