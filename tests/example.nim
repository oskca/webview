import webview

const ui = "data:text/html,<h1>Nim</h1><input id='data'><button onclick=api.cb(document.querySelector('#data').value) >OK</button>"

let webviewindow = newWebView("Title", ui)

webviewindow.bindProcs"api":
  proc cb(data: string) = (proc = echo data)()

webviewindow.run()
webviewindow.exit()
