import illwill
import std/strutils

type 
  WilllessComponent* = ref object of RootObj
    parent*: WilllessComponent
    topLevel* = false

  OverflowStyle* {.pure.} = enum Cut, Override, Crash
  WrapStyle* {.pure.} = enum Soft, Hard, None

  InlineComponent* = ref object of WilllessComponent
    subbuff*: WilllessSubBuffer
    overflow* = OverflowStyle.Crash

  SpaceComponent* = ref object of InlineComponent
    width*, height*: int
    fill* = ' '

  ExpansionStyle* {.pure.} = enum X, Y, XY, None
  FlexibleComponent* = ref object of InlineComponent
    minHeight*, minWidth*, maxWidth*, maxHeight*: int
    expansion* = ExpansionStyle.XY


  WilllessSubBuffer* = ref object
    boundingBox*: array[4, int] ## Top left (x, y)  & (x, y) bottom right
    height*: int
    width*: int
    parent: WilllessSubbuffer
    root: TerminalBuffer


proc newSubBuffer*(boundingBox: array[4, int], parent: WilllessSubbuffer): WilllessSubbuffer =
  result = WilllessSubbuffer(boundingBox: boundingBox, parent: parent)
  result.height = boundingBox[3] - boundingBox[1]
  result.width = boundingBox[2] - boundingBox[0]
  result.root = parent.root

proc newRootSubBuffer*(tb: TerminalBuffer): WilllessSubBuffer =
  result = WilllessSubBuffer(root: tb)
  result.height = tb.height
  result.width = tb.width
  result.boundingBox = [0, 0, result.height-1, result.width-1]


proc highY*(sb: WilllessSubBuffer): int {.inline.} = sb.height - 1
proc highX*(sb: WilllessSubBuffer): int {.inline.} = sb.width - 1


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


proc fill*(sb: WilllessSubBuffer, x1, y1, x2, y2: int, f: string, ov = OverflowStyle.Crash) =
  let rx1 = sb.boundingBox[0] + x1 
  let ry1 = sb.boundingBox[1] + y1
  var rx2 = sb.boundingBox[0] + x2
  var ry2 = sb.boundingBox[1] + y2

  doAssert rx1 < rx2 and ry1 < ry2
  if rx2 > sb.boundingBox[2]:
    case ov
    of Crash:
      raise ValueError.newException("Fill exceeded buffer on the x axis.")
    of Cut:
      rx2 = sb.boundingBox[2]
    else:
      discard

  if ry2 > sb.boundingBox[3]:
    case ov
    of Crash:
      raise ValueError.newException("Fill exceeded buffer on the y axis.")
    of Cut:
      ry2 = sb.boundingBox[3]
    else:
       discard

  sb.root.fill(rx1, ry1, rx2, ry2, f)


include coremethods