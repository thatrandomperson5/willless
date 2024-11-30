import willless, illwill
import willless/components/borders
import std/strutils

illwillInit(fullscreen=false)
hideCursor()
setDoubleBuffering(false)

proc countTo(i: int): string = 
  var lines: seq[string]
  for n in 0..i:
    let sn = $n
    if sn.len > lines.len:
      lines.add ""
    for i, c in sn:
      lines[i].add spaces(n - lines[i].len)
      lines[i].add c
  result = lines.join("\n")
  


var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

var wl = newView(tb)
wl.addChild() do:
  var c = newContainer()
  c.addChild(newText(countTo(tb.width - 1)))
  c.id = "root"
  var b = newBorderBox(true)
  b.id = "border1"
  b.addChild(newText("Hello world!"))
  b.addChild(newText("What's up?"))
  c.addChild(b)
  c.addChild(newBorderBox())
  c.children[2].id = "border2"
  c.addChild() do:
    var sub = newBorderBox()
    sub.id = "border3"
    sub.addChild(newText("Lower Box\nLower Box"))
    sub
  c

wl.renderLayout()
wl.renderRoot(tb)
echo "\n".repeat(50)
tb.display()