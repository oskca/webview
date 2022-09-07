import webview

const html = """
<button id="increment">Tap me</button>
<div>You tapped <span id="count">0</span> time(s).</div>
<script>
  const [incrementElement, countElement] = document.querySelectorAll("#increment, #count");
  document.addEventListener("DOMContentLoaded", () => {
    incrementElement.addEventListener("click", () => {
      window.increment(1,2,3).then(result => {
        countElement.textContent = result.count;
      });
    });
  });
</script>
"""

type
  Context = object
    w: Webview
    count: int

proc increment(ctx: pointer, seqId: string, req: string) {.nimcall.} =
  var context = cast[ptr Context](ctx)
  inc(context.count)
  echo "You tapped ", context.count, " time(s)"
  var res = "{\"count\":" & $context.count & "}"
  context.w.retVal(seqId, 0, res)

var
  w = newWebView()
  context = Context(w: w, count: 0)
w.setTitle("Bind Example").setSize( 480, 320, WEBVIEW_HINT_NONE)
w.bindProc("increment", increment, addr context).setHtml(html)
w.run().destroy();



