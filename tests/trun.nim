import willless, illwill
import willless/[text, containers]

illwillInit(fullscreen=false)
hideCursor()

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
var wl = newView(tb)
wl.addChild() do:
  var c = newContainer()
  # c.addChild(newSpace(20, 3, 'L'))
  c.addChild(newText("Hello world!"))
  c.addChild(newText("What's up?"))
  c

wl.render()
tb.display()