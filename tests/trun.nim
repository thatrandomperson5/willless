import willless, illwill
import willless/components/borders
import std/strutils

illwillInit(fullscreen=false)
hideCursor()

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
  var b = newBorderBox(true)
  b.addChild(newText("Hello world!"))
  b.addChild(newText("What's up?"))
  c.addChild(b)
  c

wl.renderLayout()
wl.renderRoot(tb)
tb.display()