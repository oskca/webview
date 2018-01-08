import webview
import os

const indexHTML = """
<!doctype html>
<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
	</head>
	<body>
		<button onclick="api.close()">Close</button>
		<button onclick="api.open()">Open</button>
		<button onclick="api.opendir()">Open directory</button>
		<button onclick="api.save()">Save</button>
		<button onclick="api.message()">Message</button>
		<button onclick="api.changeTitle(document.getElementById('new-title').value)">
			Change title
		</button>
		<input id="new-title" type="text" />
	</body>
</html>
"""
import strutils, future

import json
proc main()=
    let fn="$1/xxx.html"%[getTempDir()]
    writeFile(fn, indexHTML)
    defer: removeFile(fn)
    var w = newWebView("Simple window demo2", "file://" & fn)
    w.bindProc:
        proc close() = w.terminate()
        proc open() = echo w.dialogOpen()
        proc save() = echo w.dialogSave()
        proc opendir() = echo w.dialogOpen(flag=dFlagDir)
        proc message() = w.alert("hello", "world")
        proc changeTitle(title: string) = w.setTitle(title)
    defer: w.exit()
    w.run()

main()
