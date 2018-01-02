type
  ExternalInvokeCbT* = proc (w: ptr Webview; arg: cstring)
  Webview* {.importc: "struct webview", header: "webview.h", bycopy.} = object
    url* {.importc: "url".}: cstring
    title* {.importc: "title".}: cstring
    width* {.importc: "width".}: cint
    height* {.importc: "height".}: cint
    resizable* {.importc: "resizable".}: cint
    debug* {.importc: "debug".}: cint
    externalInvokeCb* {.importc: "external_invoke_cb".}: ExternalInvokeCbT
    priv* {.importc: "priv".}: pointer
    userdata* {.importc: "userdata".}: pointer

  DialogType* {.size: sizeof(cint).} = enum
    DIALOG_TYPE_OPEN = 0, DIALOG_TYPE_SAVE = 1, DIALOG_TYPE_ALERT = 2

type
  DispatchFn* = proc (w: ptr Webview; arg: pointer)
  DispatchArg* {.importc: "webview_dispatch_arg", header: "webview.h", bycopy.} = object
    fn* {.importc: "fn".}: DispatchFn
    w* {.importc: "w".}: ptr Webview
    arg* {.importc: "arg".}: pointer

proc init*(w: ptr Webview): cint {.importc: "webview_init", header: "webview.h".}
proc loop*(w: ptr Webview; blocking: cint): cint {.importc: "webview_loop",
    header: "webview.h".}
proc eval*(w: ptr Webview; js: cstring): cint {.importc: "webview_eval",
    header: "webview.h".}
proc injectCss*(w: ptr Webview; css: cstring): cint {.importc: "webview_inject_css",
    header: "webview.h".}
proc setTitle*(w: ptr Webview; title: cstring) {.importc: "webview_set_title",
    header: "webview.h".}
proc dialog*(w: ptr Webview; dlgtype: DialogType; flags: cint; title: cstring;
            arg: cstring; result: cstring; resultsz: csize) {.
    importc: "webview_dialog", header: "webview.h".}
proc dispatch*(w: ptr Webview; fn: DispatchFn; arg: pointer) {.
    importc: "webview_dispatch", header: "webview.h".}
proc terminate*(w: ptr Webview) {.importc: "webview_terminate", header: "webview.h".}
proc exit*(w: ptr Webview) {.importc: "webview_exit", header: "webview.h".}
proc debug*(format: cstring) {.varargs, importc: "webview_debug", header: "webview.h".}
proc printLog*(s: cstring) {.importc: "webview_print_log", header: "webview.h".}
proc webview*(title: cstring; url: cstring; w: cint; h: cint; resizable: cint): cint {.
    importc: "webview", header: "webview.h".}