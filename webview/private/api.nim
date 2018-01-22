type
  ExternalInvokeCb* = proc (w: Webview; arg: string)
  WebviewPrivObj{.importc: "struct webview_priv", header: "webview.h", bycopy.} = object
  WebviewObj* {.importc: "struct webview", header: "webview.h", bycopy.} = object
    url* {.importc: "url".}: cstring
    title* {.importc: "title".}: cstring
    width* {.importc: "width".}: cint
    height* {.importc: "height".}: cint
    resizable* {.importc: "resizable".}: cint
    debug* {.importc: "debug".}: cint
    invokeCb {.importc: "external_invoke_cb".}: pointer
    priv {.importc: "priv".}: WebviewPrivObj
    userdata {.importc: "userdata".}: pointer
  Webview* = ptr WebviewObj

  DialogType* {.size: sizeof(cint).} = enum
    dtOpen = 0, dtSave = 1, dtAlert = 2

const
  dFlagFile* = 0
  dFlagDir* = 1
  dFlagInfo* = 1 shl 1
  dFlagWarn* = 2 shl 1
  dFlagError* = 3 shl 1
  dFlagAlertMask* = 3 shl 1

type
  DispatchFn* = proc (w: Webview; arg: pointer)
  DispatchArg* {.importc: "webview_dispatch_arg", header: "webview.h", bycopy.} = object
    fn* {.importc: "fn".}: DispatchFn
    w* {.importc: "w".}: Webview
    arg* {.importc: "arg".}: pointer

proc init*(w: Webview): cint {.importc: "webview_init", header: "webview.h".}
proc loop*(w: Webview; blocking: cint): cint {.importc: "webview_loop", header: "webview.h".}
proc eval*(w: Webview; js: cstring): cint {.importc: "webview_eval", header: "webview.h".}
proc injectCss*(w: Webview; css: cstring): cint {.importc: "webview_inject_css", header: "webview.h".}
proc setTitle*(w: Webview; title: cstring) {.importc: "webview_set_title", header: "webview.h".}
proc setColor*(w: Webview; r,g,b,a: uint8) {.importc: "webview_set_color", header: "webview.h".}
proc setFullscreen*(w: Webview; fullscreen: cint) {.importc: "webview_set_fullscreen", header: "webview.h".}
proc dialog*(w: Webview; dlgtype: DialogType; flags: cint; title: cstring; arg: cstring; result: cstring; resultsz: csize) {.
    importc: "webview_dialog", header: "webview.h".}
proc dispatch*(w: Webview; fn: DispatchFn; arg: pointer) {.importc: "webview_dispatch", header: "webview.h".}
proc terminate*(w: Webview) {.importc: "webview_terminate", header: "webview.h".}
proc exit*(w: Webview) {.importc: "webview_exit", header: "webview.h".}
proc debug*(format: cstring) {.varargs, importc: "webview_debug", header: "webview.h".}
proc printLog*(s: cstring) {.importc: "webview_print_log", header: "webview.h".}
proc webview*(title: cstring; url: cstring; w: cint; h: cint; resizable: cint): cint {.importc: "webview", header: "webview.h".}