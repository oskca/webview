{.passC: "-DWEBVIEW_STATIC -DWEBVIEW_IMPLEMENTATION".}
{.passC: "-I" & currentSourcePath().substr(0, high(currentSourcePath()) - 4) .}

when defined(linux):
  {.passC:"`pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0`".}
  {.passL:"`pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0`".}
elif defined(windows):#NOT TESTED
  # {.passC:"-mwindows".}
  # {.passL:"-L./dll/x64 -lwebview -lWebView2Loader".}
  {.passC: "-DWEBVIEW_WINAPI=1".}
  {.passL: "-lole32 -lcomctl32 -loleaut32 -luuid -lgdi32".}
elif defined(macosx):
  {.passL: "-framework WebKit".}
type
  Webview* {.header:"webview.h",importc:"webview_t".} = pointer
  WebviewHint* = enum
    WEBVIEW_HINT_NONE,WEBVIEW_HINT_MIN,WEBVIEW_HINT_MAX,WEBVIEW_HINT_FIXED
proc create*(debug:cint,window:pointer):Webview{.importc:"webview_create",header:"webview.h".}
proc set_title*(w:Webview,title:cstring){.importc:"webview_set_title",header:"webview.h".}
proc set_size*(w:Webview,width:cint,height:cint,hints:WebviewHint){.importc:"webview_set_size",header:"webview.h".}
proc navigate*(w:Webview,url:cstring){.importc:"webview_navigate",header:"webview.h".}
proc run*(w:Webview){.importc:"webview_run",header:"webview.h".}
proc destroy*(w:Webview){.importc:"webview_destroy",header:"webview.h".}
