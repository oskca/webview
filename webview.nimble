# Package

version       = "0.1.0"
author        = "oskca"
description   = "Nim bindings for zserge\'s webview"
license       = "MIT"
skipDirs      = @["tests"]

# Dependencies

requires "nim >= 0.17.2"

task test, "a simple test case":
    exec "nim c -r tests/bindEx.nim"

task docs, "generate doc":
    exec "nim doc2 -o:docs/webview.html webview.nim"

task sync, "update webview.h":
    exec "wget -O webview/webview.h https://raw.githubusercontent.com/zserge/webview/master/webview.h"
    exec "wget -O webview/webview.go https://raw.githubusercontent.com/zserge/webview/master/webview.go"
    exec "wget -O webview/README.md https://raw.githubusercontent.com/zserge/webview/master/README.md"

task clean, "clean tmp files":
    exec "rm -rf nimcache"
    exec "rm -rf tests/nimcache"
