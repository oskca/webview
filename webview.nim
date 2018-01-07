when defined(linux):
  {.passC: "-I" & staticExec("pwd") & "/webview".}
  {.passC: "-DWEBVIEW_GTK=1" &
          staticExec"pkg-config --cflags gtk+-3.0 webkit2gtk-4.0".}
  {.passL: staticExec"pkg-config --libs gtk+-3.0 webkit2gtk-4.0".}
elif defined(windows):
  {.passC: "-I." & staticExec("cmd /c cd").}
  {.passC: "-DWEBVIEW_WINAPI=1".}
  {.passL: "-lole32 -lcomctl32 -loleaut32 -luuid -mwindows".}
elif defined(darwin):
  {.passC: "-I" & staticExec("pwd") & "/webview".}
  {.passC: "-DWEBVIEW_COCOA=1 -x objective-c".}
  {.passL: "-framework Cocoa -framework WebKit".}

include webview/private/api

import tables

##
## Hight level api and javascript bindings to easy bidirectonal 
## message passsing for ``nim`` and the ``webview`` .
##

# easy callbacks
var cbs = newTable[Webview, ExternalInvokeCb]()
proc generalExternalInvokeCallback(w: Webview, arg: cstring) {.exportc.} =
  if cbs.hasKey(w): cbs[w](w, $arg)

proc `externalInvokeCB=`*(w: Webview, cb: ExternalInvokeCb)=
  ## Set external invoke callback for webview
  cbs[w] = cb

proc newWebView*(title="WebView", url="", 
                 width=640, height=480, 
                 resizable=true, debug=false,
                 cb:ExternalInvokeCb=nil): Webview =
  ## ``newWebView`` creates and opens a new webview window using the given settings. 
  ## This function will do webview ``init``
  var w = cast[Webview](alloc0(sizeof(WebviewObj)))
  w.title = title
  w.url = url
  w.width = width.cint
  w.height = height.cint
  w.resizable = if resizable: 1 else: 0
  w.debug = if debug: 1 else: 0
  w.invokeCb = generalExternalInvokeCallback
  if cb != nil:
    w.externalInvokeCB=cb
  if w.init() != 0: return nil
  return w

proc dialog*(w :Webview, dlgType: DialogType, flags: int, title, arg: string): string =
  ## dialog() opens a system dialog of the given type and title. String
  ## argument can be provided for certain dialogs, such as alert boxes. For
  ## alert boxes argument is a message inside the dialog box.
  let maxPath = 4096
  let resultPtr = cast[cstring](alloc0(maxPath))
  defer: dealloc(resultPtr)
  w.dialog(dlgType, flags.cint, title.cstring, arg.cstring, resultPtr, maxPath.csize) 
  return $resultPtr

proc alert*(w: Webview, title, msg: string) =
  ## Show one alert box
  discard w.dialog(dtAlert, 0, title, msg)

proc dialogOpen*(w: Webview, title="Open File", flag=dFlagFile): string =
  ## Opens a dialog that requests filenames from the user. Returns ""
  ## if the user closed the dialog without selecting a file. 
  return w.dialog(dtOpen, flag, title, "")

proc dialogSave*(w: Webview, title="Save File", flag=dFlagFile): string =
  ## Opens a dialog that requests a filename to save to from the user.
  ## Returns "" if the user closed the dialog without selecting a file.
  return w.dialog(dtSave, flag, title, "")

proc run*(w: Webview)=
  ## ``run`` starts the main UI loop until the user closes the webview window or
  ## Terminate() is called.
  while w.loop(1) == 0:
    discard

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

