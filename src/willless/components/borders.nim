import ../[containers, utils, core]
import buju

type 
  BorderBox = ref object of Container
    doubleStyle*: bool


proc initBorderBox*(bb: BorderBox, doubleStyle=false) =
  bb.initContainer()
  bb.doubleStyle = doubleStyle
  bb.height = 2
  bb.width = 2
  super(bb): addChild(newContainer())
  bb.children[0].margin = [1, 1, 1, 1]

proc newBorderBox*(doubleStyle=false): BorderBox =
  new(result)
  result.initBorderBox(doubleStyle)

proc marginComponent(bb: BorderBox): Container {.inline.} = Container(bb.children[0])

method addChild*(bb: BorderBox, child: InlineComponent) = bb.marginComponent.addChild(child)

method makeLayout*(bb: BorderBox, l: var Layout) =
  if bb.children.len > 1:
    raise ValueError.newException("BorderBox has more than one marigin component.")
  super(bb): makeLayout(l)

method render*(bb: BorderBox, l: var Layout) =
  super(bb): render(l)
  bb.subbuff.drawRect(0, 0, bb.subbuff.highX, bb.subbuff.highY, doubleStyle=bb.doubleStyle)


proc children*(bb: BorderBox): var seq[InlineComponent] {.inline.} = bb.marginComponent.children