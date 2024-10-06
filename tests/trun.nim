import willless, illwill
import willless/text

illwillInit(fullscreen=false)
hideCursor()

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
var wl = newView(tb)
wl.addChild(newText("Hello World!"))

wl.render()
tb.display()