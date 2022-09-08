from os import splitPath, `/`
from strutils import `%`
import macros

const
  WEBVIEW_DIR = currentSourcePath().splitPath.head /  "webview"
  SCOPED_NAME_FORMAT = "__$1_$2"

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
  webview_t = ptr object
  webview_dispatch_fn = proc (w: webview_t, arg: pointer) {.nimcall.}
  webview_bind_fn = proc (seqId: cstring, req: cstring, arg: pointer) {.nimcall.}

  WebviewCallback = object
    ## Store pointers to callback functions and thier args
    fn: pointer
    arg: pointer


  Webview* = object of RootObj
    ## High level Webview object wrapper
    impl: webview_t ## pointer to webview implementation
    ptrs: seq[ptr WebviewCallback] ## save callbacks to prevent they are bieing GC'ed, will be free'd when call `destroy()`

  Window* = ptr object
    ## Pointer to native window handler

  DispatchFn* = proc(ctx: pointer) {.nimcall.}
  BindFn* = proc(ctx: pointer, seqId: string, req: string) {.nimcall.}
    ## Nim callback for JavaScript function


  WEBVIEW_HINT* = enum
    WEBVIEW_HINT_NONE
      ## Width and height are default size
    WEBVIEW_HINT_MIN
      ## Width and height are minimum bounds
    WEBVIEW_HINT_MAX
      ## Width and height are maximum bounds
    WEBVIEW_HINT_FIXED
      ## Window size can not be changed by a user

{.push importc, header: "webview.h".}
proc webview_create(debug = false, window: Window = nil): webview_t
proc webview_destroy(w: webview_t)
proc webview_run(w: webview_t)
proc webview_terminate(w: webview_t)
proc webview_dispatch(w: webview_t, fn: webview_dispatch_fn, arg: pointer)
proc webview_get_window(w:webview_t): Window
proc webview_set_title(w:webview_t, title: cstring)
proc webview_set_size(w: webview_t, width, height: int, hints: WEBVIEW_HINT)
proc webview_navigate(w: webview_t, url: cstring)
proc webview_set_html(w: webview_t, html: cstring)
proc webview_init(w: webview_t, js: cstring)
proc webview_eval(w: webview_t, js: cstring)
proc webview_bind(w: webview_t, name: cstring, fn: webview_bind_fn, arg: pointer)
proc webview_unbind(w: webview_t, name: cstring)
proc webview_return(w: webview_t, seqId: cstring, status: int32, result: cstring)
{.pop.}

##
## Hight level api and javascript bindings to easy bidirectonal
## message passsing for ``nim`` and the ``webview`` .
##

proc newWebview*(title = "WebView", url = "", width = 640, height = 480, resizable = true, debug = false): Webview {.discardable.} =
  ## Creates a new webview instance.

  result.impl = webview_create(debug)
  webview_set_title(result.impl, title)
  webview_set_size(result.impl, width, height, if resizable: WEBVIEW_HINT_NONE else: WEBVIEW_HINT_FIXED)

proc destroy*(w: Webview) =
  ## Destroys a webview and closes the native window.

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

proc dispatch*(w: Webview, fn: DispatchFn, arg: pointer): Webview {.discardable.} =
  ## Posts a function to be executed on the main thread.. You normally do not need
  ## to call this function, unless you want to tweak the native window.

  var ctx = cast[ptr WebviewCallback](alloc0(sizeof(WebviewCallback)))
  ctx.fn = fn
  ctx.arg = arg

  var dispatchFn = proc (w: webview_t, ctx: pointer) =

    var context = cast[ptr WebviewCallback](ctx)
    cast[DispatchFn](context.fn)(context.arg)

    # free context
    dealloc(ctx)

  webview_dispatch(w.impl, dispatchFn, ctx)
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

proc bindProc*(w: var Webview, name: string, fn: BindFn, arg: pointer): Webview {.discardable.} =
  ## Binds a Nim callback so that it will appear under the given name as a
  ## global JavaScript function.

  var ctx = cast[ptr WebviewCallback](alloc0(sizeof(WebviewCallback)))
  ctx.fn = fn
  ctx.arg = arg

  w.ptrs.add(ctx)

  var bindFn = proc (seqId: cstring, req: cstring, ctx: pointer) =
    let context = cast[ptr WebviewCallback](ctx)
    cast[BindFn](context.fn)(context.arg, $seqId, $req)
  webview_bind(w.impl, name, bindFn, ctx)

  return w

proc bindScope*(w: var Webview, scope, name: string, fn: BindFn, arg: pointer): Webview {.discardable.} =
  ## Binds a Nim callback so that it will appear under the given name as a
  ## global JavaScript function.

  var ctx = cast[ptr WebviewCallback](alloc0(sizeof(WebviewCallback)))
  ctx.fn = fn
  ctx.arg = arg

  w.ptrs.add(ctx)

  var bindFn = proc (seqId: cstring, req: cstring, ctx: pointer) =
    let context = cast[ptr WebviewCallback](ctx)
    cast[BindFn](context.fn)(context.arg, $seqId, $req)

  let fnName = SCOPED_NAME_FORMAT % [scope, name]
  webview_bind(w.impl, fnName, bindFn, ctx)

  let js = "window.$1 = window.$1 || {};window.$1.$2 = window['$3'];delete window['$3'];" % [scope, name, fnName]
  echo js
  w.initJs(js)
  w.eval(js)
  return w

proc unbind*(w: Webview, name: string, scope = ""): Webview {.discardable.} =
  ## Removes a Nim callback that was previously set by `bind()`
  if scope.len > 0:
    webview_unbind(w.impl, SCOPED_NAME_FORMAT % [scope, name])
  else:
    webview_unbind(w.impl, name)
  return w

proc retVal*(w: Webview, seqId: string, status: int32, data: string): Webview {.discardable.} =
  ## Allows to return a value from the native binding.
  webview_return(w.impl, seqId, status, data)
  return w

when isMainModule:
  var w = newWebview()
  w.setHtml("Thanks for using webview!")
  w.run()
  w.destroy()