import core, utils
import std/tables


type 
  Direction* {.pure.} = enum Up, Down, Left, Right
  Container* = ref object of InlineComponent
    children*: seq[InlineComponent]
    direction* = Direction.Down
    sizing: seq[(int, int)] # Internal

  FlexContainer* = ref object of Container


proc initContainer*(c: Container, direction = Direction.Down) = c.direction = direction

proc newContainer*(direction = Direction.Down): Container =
  new(result)
  result.initContainer(direction)

method addChild*(c: Container, child: InlineComponent) =
  child.parent = c
  c.children.add child



template maxAccessor[T](s: openArray[T], acc: untyped, inital: untyped): untyped {.dirty.} =
  block:
    let a = s
    var res = inital
    for i in 1..high(s):
      if res < acc: res = acc
    res

template applyConstraints(): untyped {.dirty.} =
  for i in 0..high(c.sizing):
    if c.sizing[i] == (-1, -1):
      doAssert c.children[i].restrictedSizeCalc(constraints)
      c.sizing[i] = (c.children[i].width, c.children[i].height)


method initalSizeCalc*(c: Container): Constraint =
  result = Constraint.None
  var requested: set[Constraint]

  var hasSolids = false
  for child in c.children:
    let rq = child.initalSizeCalc()
    if rq != Constraint.None: 
      requested.incl rq
      c.sizing.add (-1, -1)
    else:
      hasSolids = true
      c.sizing.add (child.width, child.height)

  if not hasSolids:
    if c.direction in {Direction.Up, Direction.Down}:
      return Constraint.Width
    else:
      return Constraint.Height

  var constraints = newTable[Constraint, int](2)
  if Width in requested and c.direction in {Direction.Up, Direction.Down}:
    constraints[Width] = maxAccessor(c.sizing, a[i][0], a[0][0])
  elif Height in requested and c.direction in {Direction.Left, Direction.Right}:
    constraints[Height] = maxAccessor(c.sizing, a[i][1], a[0][1])

  applyConstraints()

method restrictedSizeCalc*(c: Container, ct: ConstraintTable): bool =
  result = true

  var constraints = newTable[Constraint, int](2)
  if c.direction in {Direction.Up, Direction.Down}:
    constraints[Width] = ct[Width]
  else:
    constraints[Height] = ct[Height]
  
  applyConstraints()
  

method render*(c: Container) =
  if c.sizing.len == 0:
    raise ValueError.newException("Cannot render container that has not been sized!")

  var x = 0
  var y = 0
  if c.direction == Direction.Up:
    y = c.subbuff.highY
  if c.direction == Direction.Left:
    x = c.subbuff.highX

  for i in 0..high(c.sizing):
    var child = c.children[i]
    let width = c.sizing[i][0]
    let height = c.sizing[i][1]
    
    child.subbuff = newSubBufferFrom([x, y, x+width-1, y+height-1], c.subbuff)
    echo child.subbuff[]
    child.render()
    case c.direction:
    of Down:
      y += height 
    of Up:
      y -= height
    of Right:
      x += width
    of Left:
      x -= width
  

  