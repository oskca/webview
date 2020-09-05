# Webview binding for nim

Nim bindings for [zserge's Webview](https://github.com/webview/webview) which is Tiny cross-platform webview library for C/C++/Golang. Uses WebKit (Gtk/Cocoa) and Edge (Windows) 

# E.G.

```nim
import webview

var w = create(0,nil)
w.set_title("Webview Nim Example")
w.set_size(480, 320, WEBVIEW_HINT_NONE)
w.navigate("https://en.m.wikipedia.org/wiki/Main_Page")
w.run()
w.destroy()
```



# API Docs

Documentation is [here](http://htmlpreview.github.io/?https://github.com/oskca/webview/blob/master/docs/webview.html)


When on `debian/ubuntu` `libwebkit2gtk-4.0-dev` is required as `debian/ubuntu`.
