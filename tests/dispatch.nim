import webview

const html = """
<h3>Hello world</h3>
"""

var
  w = newWebView(debug = true)

proc post(ctx: pointer) =
  var num = cast[int](ctx)
  echo "posted a number: ", num
  w.eval("alert('Check your stdout');")


w.setTitle("Dispatch Example").setSize( 480, 320, WEBVIEW_HINT_NONE)
w.setHtml(html);
w.dispatch(post, cast[pointer](99))
w.run().destroy();
