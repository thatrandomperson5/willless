import willless/[core], illwill

type ViewComponent* = ref object of WilllessComponent
  child*: InlineComponent
  modal*: WilllessComponent
  subbuff*: WilllessSubbuffer

proc initViewComponent*(v: ViewComponent, tb: TerminalBuffer) = 
  v.topLevel = true
  v.subbuff = newRootSubBuffer(tb)

proc newView*(tb: TerminalBuffer): ViewComponent =
  new(result)
  result.initViewComponent(tb)


method addChild*(v: ViewComponent, child: InlineComponent) =
  child.parent = v
  # child.subbuff = newSubBuffer([0, 0, v.subbuff.highX, v.subbuff.highY], v.subbuff) # Inital buffer
  v.child = child

method render*(v: ViewComponent) =
  v.child.subbuff = newSubBuffer([0, 0, v.subbuff.highX, v.subbuff.highY], v.subbuff)
  v.child.render()

method renderRoot*(v: ViewComponent, tb: TerminalBuffer) {.base.} =
  v.subbuff = newRootSubBuffer(tb)
  v.render()


export core