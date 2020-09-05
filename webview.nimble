# Package

version       = "0.1.1"
author        = "oskca"
description   = "Nim bindings for zserge\'s webview"
license       = "MIT"
skipDirs      = @["tests"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.0"

task docs, "generate doc":
    exec "nim doc2 -o:docs/webview.html src/webview.nim"

task sync, "update webview.h":
    exec "curl -o webview/webview.h https://raw.githubusercontent.com/webview/webview/master/webview.h"
    exec "curl -o webview/README.md https://raw.githubusercontent.com/webview/webview/master/README.md"

task example, "running minimal example":
    exec "nim r tests/minimal.nim"

task clean, "clean tmp files":
    exec "rm -rf nimcache"
    exec "rm -rf tests/nimcache"
