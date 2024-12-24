# UI Test, does not run with nimble test

import os, illwill, willless
import willless/components/borders

illwillInit(fullscreen=false)
hideCursor()
setDoubleBuffering(false)

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

setControlCHook(exitProc)


const ipsumText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."


var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
var root = newView(tb)
root.addChild() do:
  var main = newBorderBox(true)
  main.addChild() do:
    var ipsum = newBorderBox()
    ipsum.addChild(newText(ipsumText))
    ipsum.style.margin = 1
    ipsum

  main.addChild() do:
    var boxGroup = newBorderBoxGroup()
    boxGroup.addChild("Hello World!")
    boxGroup.addChild("Hello World!")
  main

root.renderLayout()


while true:
  tb = newTerminalBuffer(terminalWidth(), terminalHeight()) # Adjust height
  root.renderRoot(tb)
  tb.display()
  sleep(20)
