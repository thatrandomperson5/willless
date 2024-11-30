import willless/[core, utils, containers, text]
import illwill, buju
when defined(willlessDebug):
  import willless/debugTools

type ViewComponent* = ref object of WilllessComponent
  child*: InlineComponent
  modal*: WilllessComponent
  subbuff*: WilllessSubbuffer
  layout: Layout
  layoutComputed = false

proc initViewComponent*(v: ViewComponent, tb: TerminalBuffer) = 
  if hasDoubleBuffering():
    raise ValueError.newException("Illwill is currently using default double buffer, which is incompatible with willless changing sizes.")
  v.topLevel = true
  v.subbuff = newRootSubBuffer(tb)
  v.layoutNode = v.layout.node()

proc newView*(tb: TerminalBuffer): ViewComponent =
  new(result)
  result.initViewComponent(tb)


method addChild*(v: ViewComponent, child: InlineComponent) =
  child.parent = v
  # child.subbuff = newSubBuffer([0, 0, v.subbuff.highX, v.subbuff.highY], v.subbuff) # Inital buffer
  v.child = child


method makeLayout*(v: ViewComponent, l: var Layout) =
  super(v): makeLayout(l)
  v.layoutComputed = true
  makeLayout(v.child, l)
  l.insertChild(v.layoutNode, v.child.layoutNode)
  
method editLayout*(v: ViewComponent, l: var Layout) =
  when defined(willlessDebug) and defined(willlessDebugLayoutEdits):
    debug "Internal Root^: ", l.computed(v.layoutNode)
    debug v.child.id, "^: ", l.computed(v.child.layoutNode)
  editLayout(v.child, l)

method render*(v: ViewComponent, l: var Layout) =
  let comp = l.computed(v.layoutNode)
  v.child.subbuff = newSubBufferFrom(comp, v.subbuff)

  when defined(willlessDebug) and defined(willlessDebugBuffers):
    debug v.child.id, ": ", v.child.subbuff[]

  if v.child.usesSpace():
    v.child.render(l)



method renderLayout*(v: ViewComponent) {.base.} = v.makeLayout(v.layout)
  # Inital layout construction call (step 2)

method renderRoot*(v: ViewComponent, tb: TerminalBuffer) {.base.} =
  # Per tick (step 3)

  v.subbuff = newRootSubBuffer(tb)
  if not v.layoutComputed:
    raise ValueError.newException("No layout has been rendered for this view.")

  v.layout.setSize(v.layoutNode, vec2(v.subbuff.width.float, v.subbuff.height.float)) # Size must be changed before pre-computation
  v.layout.compute(v.layoutNode) # Step 3.1
  v.editLayout(v.layout) # Step 3.2
  v.layout.compute(v.layoutNode) # Step 3.3
  v.render(v.layout) # Step 3.4


export core, containers, text, LayoutBoxWrap, LayoutBoxStart, LayoutBoxEnd,
    LayoutBoxJustify, LayoutBoxRow, LayoutBoxColumn, LayoutLeft, LayoutTop,
    LayoutRight, LayoutBottom, LayoutHorizontalFill, LayoutVerticalFill, LayoutFill

