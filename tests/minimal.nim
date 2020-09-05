import webview

var w = create(0,nil)
w.set_title("Webview Nim Example")
w.set_size(480,320,WEBVIEW_HINT_NONE)
w.navigate("https://nim-lang.org/")
w.run()
w.destroy()
