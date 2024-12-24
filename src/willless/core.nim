import illwill
import std/strutils
import buju
import utils

type 
  WilllessComponent* = ref object of RootObj
    parent*: WilllessComponent
    topLevel* = false
    layoutNode*: LayoutNodeID
    layoutFlags*: int
    margin* = [0, 0, 0, 0]
    width*, height*: int
    id*: string

  OverflowStyle* {.pure.} = enum Cut, Override, Crash
  WrapStyle* {.pure.} = enum Soft, Hard, None

  InlineComponent* = ref object of WilllessComponent
    subbuff*: WilllessSubBuffer
    overflow* = OverflowStyle.Crash

  SpaceComponent* = ref object of InlineComponent
    ch* = ' '

  #[ Deprecated with the new use of buju
  ExpansionStyle* {.pure.} = enum X, Y, XY, None
  ExpandingComponent* = ref object of InlineComponent
    minHeight*, minWidth*, maxWidth*, maxHeight*: int
    expansion* = ExpansionStyle.XY
    child*: InlineComponent
  ]#

  WilllessSubBuffer* = ref object
    boundingBox*: array[4, int] ## Top left (x, y)  & (x, y) bottom right
    height*: int
    width*: int
    parent: WilllessSubbuffer
    root: TerminalBuffer
    boxRoot: BoxBuffer


proc newSubBuffer*(boundingBox: array[4, int], parent: WilllessSubBuffer): WilllessSubBuffer =
  result = WilllessSubbuffer(boundingBox: boundingBox, parent: parent)
  result.height = boundingBox[3] - boundingBox[1] + 1
  result.width = boundingBox[2] - boundingBox[0] + 1
  result.root = parent.root
  result.boxRoot = parent.boxRoot


proc newSubBufferFrom*(v4: Vec4, parent: WilllessSubBuffer): WilllessSubBuffer =
  result = WilllessSubBuffer(parent: parent)

  let bounds = getSubBufferBounds(v4)
  result.boundingBox = bounds.boundingBox
  result.width = bounds.width
  result.height = bounds.height

  result.root = parent.root
  result.boxRoot = parent.boxRoot

proc newSubBufferFrom*(relativeBounds: array[4, int], parent: WilllessSubBuffer): WilllessSubBuffer {.deprecated.} =
  ## Create a new sub-buffer with bounds relative to the parent. Deprecated due to buju using absolute bounds.
  var bounds = relativeBounds
  bounds[0] += parent.boundingBox[0]
  bounds[1] += parent.boundingBox[1]
  bounds[2] += parent.boundingBox[0]
  bounds[3] += parent.boundingBox[1]
  result = newSubBuffer(bounds, parent) 
  doAssert bounds[2] <= parent.boundingBox[2]
  doAssert bounds[3] <= parent.boundingBox[3]

proc newRootSubBuffer*(tb: TerminalBuffer): WilllessSubBuffer =
  result = WilllessSubBuffer(root: tb)
  result.boxRoot = newBoxBuffer(tb.width, tb.height)
  result.height = tb.height
  result.width = tb.width
  result.boundingBox = [0, 0, result.height-1, result.width-1]


proc highY*(sb: WilllessSubBuffer): int {.inline.} = sb.height - 1
proc highX*(sb: WilllessSubBuffer): int {.inline.} = sb.width - 1


proc writeBoxRoot*(sb: WilllessSubBuffer) {.inline.} = sb.root.write(sb.boxRoot)


# Wrappers of default illwill write procs

proc write*(sb: WilllessSubBuffer, x, y: int, s: string, ov: OverflowStyle) =
  let realX = sb.boundingBox[0] + x
  let realY = sb.boundingBox[1] + y
  var lines = s.splitLines()

  if (lines.len + y) > sb.height:
    case ov
    of Crash:
      raise ValueError.newException("Write exceeded buffer bounds on the y axis.")
    of Cut:
      let diff = sb.highY - y
      lines = lines[0..diff]
    else:
      discard

  for i, line in lines:
    var line = line
    if (line.len + x) > sb.width:
      case ov
      of Crash:
        raise ValueError.newException("Write exceeded buffer bounds on the x axis.")
      of Cut:
        let diff = sb.highX - x
        line = line[0..diff]
      else:
        discard
    
    sb.root.write(realX, realY + i, line)
        

  

proc write*(sb: WilllessSubBuffer, s: string, ov = OverflowStyle.Crash) {.inline.} = sb.write(0, 0, s, ov)


proc adjustCords(sb: WilllessSubBuffer, x1, y1, x2, y2: int, ov = OverflowStyle.Crash): array[4, int] =
  let rx1 = sb.boundingBox[0] + x1 
  let ry1 = sb.boundingBox[1] + y1
  var rx2 = sb.boundingBox[0] + x2
  var ry2 = sb.boundingBox[1] + y2

  doAssert rx1 <= rx2 and ry1 <= ry2, "rx1: " & $rx1 & " rx2: " & $rx2 & " ry1: " & $ry1 & " ry2: " & $ry2 # Cords are inclusive
  if rx2 > sb.boundingBox[2]:
    case ov
    of Crash:
      raise ValueError.newException("Modification exceeded buffer on the x axis.")
    of Cut:
      rx2 = sb.boundingBox[2]
    else:
      discard

  
  if ry2 > sb.boundingBox[3]:
    case ov
    of Crash:
      raise ValueError.newException("Modification exceeded buffer on the y axis.")
    of Cut:
      ry2 = sb.boundingBox[3]
    else:
       discard

  result = [rx1, ry1, rx2, ry2]

proc fill*(sb: WilllessSubBuffer, x1, y1, x2, y2: int, f: string, ov = OverflowStyle.Crash) =
  let c = sb.adjustCords(x1, y1, x2, y2, ov)
  sb.root.fill(c[0], c[1], c[2], c[3], f)

proc drawRect*(sb: WilllessSubBuffer, x1, y1, x2, y2: int, doubleStyle: bool, useBox = false, ov = OverflowStyle.Crash) =
  let c = sb.adjustCords(x1, y1, x2, y2, ov)
  if useBox:
    sb.boxRoot.drawRect(c[0], c[1], c[2], c[3], doubleStyle)
  else:
    sb.root.drawRect(c[0], c[1], c[2], c[3], doubleStyle)


include coremethods
