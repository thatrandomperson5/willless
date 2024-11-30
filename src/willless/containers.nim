import core, utils
import buju
when defined(willlessDebug):
  import debugTools

type 
  Container* = ref object of InlineComponent
    children*: seq[InlineComponent]
    boxFlags*: int


# Generic Container

proc initContainer*(c: Container) = 
  c.boxFlags = LayoutBoxColumn
  c.layoutFlags = LayoutFill

proc newContainer*(): Container =
  new(result)
  result.initContainer()

method addChild*(c: Container, child: InlineComponent) =
  child.parent = c
  c.children.add child

method makeLayout*(c: Container, l: var Layout) = 
  super(c): makeLayout(l)
  l.setBoxFlags(c.layoutNode, c.boxFlags)
  for child in c.children:
    makeLayout(child, l)
    l.insertChild(c.layoutNode, child.layoutNode)

method editLayout*(c: Container, l: var Layout) =
  for child in c.children:
    when defined(willlessDebug) and defined(willlessDebugLayoutEdits):
      debug child.id, "^: ", l.computed(child.layoutNode)
    editLayout(child, l)

method render*(c: Container, l: var Layout) =
  for child in c.children:
    let comp = l.computed(child.layoutNode)
    child.subbuff = newSubBufferFrom(comp, c.subbuff)
    
    when defined(willlessDebug) and defined(willlessDebugBuffers):
      debug child.id, ": ", child.subbuff[]

    if child.usesSpace:
      child.render(l)


