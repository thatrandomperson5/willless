import core, utils


type 
  Direction* {.pure.} = enum Up, Down, Left, Right
  Container* = ref object of InlineComponent
    children*: seq[InlineComponent]
    direction* = Direction.Down

  FlexContainer* = ref object of Container


proc initContainer*(c: Container, direction = Direction.Down) = c.direction = direction

proc newContainer*(direction = Direction.Down): Container =
  new(result)
  result.initContainer(direction)

method addChild*(c: Container, child: InlineComponent) =
  child.parent = c
  c.children.add child





method render*(c: Container) =
  var sizes: seq[(int, int)]
  for child in c.children:
    if child is ExpandingComponent:
      let echild = ExpandingComponent(child)
      sizes.add (-echild.minWidth, -echild.minHeight)
    else:
      child.preSize()
      sizes.add (child.width, child.height)
  

  