import os

const WEBVIEW_DIR = currentSourcePath().splitPath.head /  "webview"

when defined(c):
  {.passL: "-lstdc++ ".}
  {.compile: "webview.cpp".}

{.passC: "-Wall -Wextra -pedantic -I" & WEBVIEW_DIR .}
when defined(linux):
  {.passC: "-DWEBVIEW_GTK=1 " & staticExec"pkg-config --cflags gtk+-3.0 webkit2gtk-4.0".}
  {.passL: staticExec"pkg-config --libs gtk+-3.0 webkit2gtk-4.0".}
elif defined(windows):
  {.passC: "-DWEBVIEW_WINAPI=1".}
  {.passL: "-lole32 -lcomctl32 -loleaut32 -luuid -lgdi32".}
elif defined(macosx):
  {.passC: "-DWEBVIEW_COCOA=1 -x objective-c".}
  {.passL: "-framework Cocoa -framework WebKit".}


type
  webview_t* = ptr object
  webview_dispatch_fn* = proc (w: webview_t, arg: ptr Webview)
  webview_bind_fn* = proc (seqId: cstring, req: cstring, arg: pointer)

  WebviewContext = object
    fn: pointer
    arg: pointer


  Webview* = object of RootObj
    impl: webview_t
    ptrs: seq[ptr WebviewContext]

  Window* = ptr object

  DispatchFn* = proc()
  BindFn* = proc(ctx: pointer, seqId: string, req: string) {.nimcall.}


  WEBVIEW_HINT* = enum
    WEBVIEW_HINT_NONE
    WEBVIEW_HINT_MIN
    WEBVIEW_HINT_MAX
    WEBVIEW_HINT_FIXED

proc webview_create*(debug = false, window: Window = nil): webview_t {.importc, header: "webview.h".}
proc webview_destroy*(w: webview_t) {.importc, header: "webview.h".}
proc webview_run*(w: webview_t) {.importc, header: "webview.h".}
proc webview_terminate*(w: webview_t) {.importc, header: "webview.h".}
proc webview_dispatch*(w: webview_t, fn: webview_dispatch_fn, arg: pointer) {.importc, header: "webview.h".}
proc webview_get_window*(w:webview_t): Window {.importc, header: "webview.h".}
proc webview_set_title*(w:webview_t, title: cstring) {.importc, header: "webview.h".}
proc webview_set_size*(w: webview_t, width, height: int, hints: WEBVIEW_HINT) {.importc, header: "webview.h".}
proc webview_navigate*(w: webview_t, url: cstring) {.importc, header: "webview.h".}
proc webview_set_html*(w: webview_t, html: cstring) {.importc, header: "webview.h".}
proc webview_init*(w: webview_t, js: cstring) {.importc, header: "webview.h".}
proc webview_eval*(w: webview_t, js: cstring) {.importc, header: "webview.h".}
proc webview_bind*(w: webview_t, name: cstring, fn: pointer, arg: pointer) {.importc, header: "webview.h".}
proc webview_unbind*(w: webview_t, name: cstring) {.importc, header: "webview.h".}
proc webview_return*(w: webview_t, seqId: cstring, status: int32, result: cstring) {.importc, header: "webview.h".}


##
## Hight level api and javascript bindings to easy bidirectonal
## message passsing for ``nim`` and the ``webview`` .
##


proc newWebView*(title = "WebView", url = "", width = 640, height = 480, resizable = true, debug = false): Webview {.discardable.} =
  ## Creates a new webview instance.
  #result  = new(Webview)

  result.impl = webview_create(debug)
  webview_set_title(result.impl, title)
  webview_set_size(result.impl, width, height, if resizable: WEBVIEW_HINT_NONE else: WEBVIEW_HINT_FIXED)
  webview_set_html(result.impl, "Thanks for using webview!")

proc destroy*(w: WebView) =
  # Destroys a webview and closes the native window.

  for pt in w.ptrs:
    dealloc(pt)
  webview_destroy(w.impl)

proc run*(w: Webview): Webview {.discardable.} =
  ## Runs the main loop until it's terminated. After this function exits - you
  ## must destroy the webview.

  webview_run(result.impl)
  return w

proc terminate*(w: Webview): Webview {.discardable.} =
  ## Stops the main loop. It is safe to call this function from another other
  ## background thread.

  webview_terminate(result.impl)
  return w

proc dispatch*(w: Webview, fn: webview_dispatch_fn): Webview {.discardable.} =
  ## Posts a function to be executed on the main thread.

  webview_dispatch(w.impl, fn, w.unsafeAddr)
  return w

proc getWindow*(w: Webview): Window =
  ## Returns a native window handle pointer

  result = webview_get_window(w.impl)

proc setTitle*(w: Webview, title: string): Webview {.discardable.} =
  ## Updates the title of the native window. Must be called from the UI thread.

  webview_set_title(w.impl, title)
  return w

proc setSize*(w: Webview, width, height: int, hints: WEBVIEW_HINT): Webview {.discardable.} =
  ## Updates native window size. See WEBVIEW_HINT constants.

  webview_set_size(w.impl, width, height, hints)
  return w

proc navigate*(w: Webview, url: string): Webview {.discardable.} =
  ## Navigates webview to the given URL. URL may be a properly encoded data URI.

  webview_navigate(w.impl, url)
  return w

proc setHtml*(w: Webview, html: string): Webview {.discardable.} =
  ## Set webview HTML directly.

  webview_set_html(w.impl, html)
  return w

proc initJs*(w: Webview, js: string): Webview {.discardable.} =
  ## Injects JavaScript code at the initialization of the new page

  webview_init(w.impl, js)
  return w

proc eval*(w: Webview, js: string): Webview {.discardable.} =
  ## Evaluates arbitrary JavaScript code

  webview_eval(w.impl, js)
  return w

proc bindProc*(w: var Webview, name: string, fn: pointer, arg: pointer): Webview {.discardable.} =
  ## Binds a Nim callback so that it will appear under the given name as a
  ## global JavaScript function.

  var ctx = cast[ptr WebviewContext](alloc0(sizeof(WebviewContext)))
  ctx.fn = fn
  ctx.arg = arg

  w.ptrs.add(ctx)

  var bindFn = proc (seqId: cstring, req: cstring, ctx: pointer) {.cdecl.} =
    var context = cast[ptr WebviewContext](ctx)
    cast[BindFn](context.fn)(context.arg, $seqId, $req)

  webview_bind(w.impl, name.cstring, bindFn, ctx)
  return w

proc unbind*(w: Webview, name: string): Webview {.discardable.} =
  ## Removes a Nim callback that was previously set by `bind()`
  webview_unbind(w.impl, name)
  return w

proc retVal*(w: Webview, seqId: string, status: int32, data: string): Webview {.discardable.} =
  ## Allows to return a value from the native binding.
  webview_return(w.impl, seqId, status, data)
  return w

when isMainModule:
  var w = newWebView()
  w.run()
  w.destroy()