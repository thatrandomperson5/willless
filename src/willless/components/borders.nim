import ../[containers, utils, core, styles]
import buju

type 
  BorderBox* = ref object of Container
    doubleStyle*: bool

  BorderBoxGroup* = ref object of Container
    doubleStyle*: bool
    mergeWithParentBox* = true
    direction* = ContainerColumn

# Normal BorderBox

proc initBorderBox*(bb: BorderBox, doubleStyle=false) =
  bb.initContainer()
  bb.doubleStyle = doubleStyle
  bb.height = 2
  bb.width = 2
  super(bb): addChild(newContainer())
  bb.children[0].style.margin = 1

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
  bb.drawRect(0, 0, bb.subbuff.highX, bb.subbuff.highY, doubleStyle=bb.doubleStyle)


proc children*(bb: BorderBox): var seq[InlineComponent] {.inline.} = bb.marginComponent.children




# Group BorderBox

proc initBorderBoxGroup*(bb: BorderBoxGroup, doubleStyle=false) =
  bb.initContainer()
  bb.doubleStyle = doubleStyle
  bb.height = 2
  bb.width = 2

proc newBorderBoxGroup*(doubleStyle=false): BorderBoxGroup =
  new(result)
  result.initBorderBoxGroup(doubleStyle)


method makeLayout*(bb: BorderBoxGroup, l: var Layout) =
  for i, child in bb.children:
    inc child.margin[0]
    inc child.margin[1]
    inc child.margin[2]
    inc child.margin[3]
    if i > 0:
      if bb.direction == ContainerColumn:
        child.margin[1] -= 1 # Remove margin from top
      elif bb.direction == ContainerRow:
        child.margin[0] -= 1 # Remove margin from left

  procCall Container(bb).makeLayout(l)

method addChild*(bb: BorderBoxGroup, child: InlineComponent) =
  procCall Container(bb).addChild(child)

# method render*(bb: BorderBoxGroup)

# Styles
proc doubleBar*[T: BorderBox](wand: StyleWand[T]): bool {.inline.} = wand.target.doubleStyle

proc `doubleBar=`*[T: BorderBox](wand: StyleWand[T], val: bool) {.inline.} = wand.target.doubleStyle = val
