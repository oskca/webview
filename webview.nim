when defined(linux):
  {.passC: "-I" & staticExec("pwd") & "/clibs".}
  {.passC: "-DWEBVIEW_GTK=1" &
          staticExec"pkg-config --cflags gtk+-3.0 webkitgtk-3.0".}
  {.passL: staticExec"pkg-config --libs gtk+-3.0 webkitgtk-3.0".}
elif defined(windows):
  {.passC: "-I." & staticExec("cmd /c cd").}
  {.passC: "-DWEBVIEW_WINAPI=1".}
  {.passL: "-lole32 -lcomctl32 -loleaut32 -luuid -mwindows".}
elif defined(darwin):
  {.passC: "-I" & staticExec("pwd") & "/clibs".}
  {.passC: "-DWEBVIEW_COCOA=1 -x objective-c".}
  {.passL: "-framework Cocoa -framework WebKit".}

include api

##
## hight level api
##

proc newWebView*(title="WebView", url="", width=640, height=480, resizable=true, debug=false):ptr Webview=
  ## New creates and opens a new webview window using the given settings. 
  ## This function will not do webview init
  var w = cast[ptr Webview](alloc0(sizeof(Webview)))
  w.title = title
  w.url = url
  w.width = width.cint
  w.height = height.cint
  w.resizable = if resizable: 1 else: 0
  w.debug = if debug: 1 else: 0
  return w

proc run*(w:ptr Webview)=
  ## Run() starts the main UI loop until the user closes the webview window or
  ## Terminate() is called.
  discard w.init
  while true:
    discard w.loop(1)

proc open*(title="WebView", url="", width=640, height=480, resizable=true):int {.discardable.} =
  ## Open is a simplified API to open a single native window with a full-size webview in
  ## it. It can be helpful if you want to communicate with the core app using XHR
  ## or WebSockets (as opposed to using JavaScript bindings).
  ##
  ## Window appearance can be customized using title, width, height and resizable parameters.
  ## URL must be provided and can user either a http or https protocol, or be a
  ## local file:// URL. On some platforms "data:" URLs are also supported
  ## (Linux/MacOS).
  webview(title.cstring, url.cstring, width.cint, height.cint, (if resizable: 1 else: 0).cint)

when isMainModule:
  # open("中文标题", "http://www.bing.com", 800, 600, true)
  var w = newWebView("test", "https://www.bing.com")
  w.run
