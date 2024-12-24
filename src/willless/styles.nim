import core
import std/sequtils
import buju

type 
  StyleWand*[T: WilllessComponent] = ref object
    target*: T ## The target affected by the wand
    alignCache: int
    fillCache: int

  StyleError* = object of ValueError
  
  AlignStyle* = enum 
    AlignNone = 0x00
    AlignLeft = LayoutLeft
    AlignTop = LayoutTop
    AlignRight = LayoutRight
    AlignBottom = LayoutBottom
  FillStyle* = enum
    FillNone = 0x00
    FillHorizontal = LayoutHorizontalFill
    FillVertical = LayoutVerticalFill
    FillAll = LayoutFill


method style*(c: WilllessComponent): StyleWand[WilllessComponent] {.base.} = 
  new(result)
  result.target = c


# Margin
proc margin*[T: WilllessComponent](wand: StyleWand[T]): array[4, int] {.inline.} = wand.target.margin
proc `margin=`*[T: WilllessComponent](wand: StyleWand[T], val: int) {.inline.} =
  wand.target.margin = [val, val, val, val]
proc `margin=`*[T: WilllessComponent](wand: StyleWand[T], val: array[4, int]) {.inline.} = wand.target.margin = val

proc marginLeft*[T: WilllessComponent](wand: StyleWand[T]): int {.inline.} = wand.target.margin[0]
proc `marginLeft=`*[T: WilllessComponent](wand: StyleWand[T], val: int) {.inline.} = wand.target.margin[0] = val

proc marginTop*[T: WilllessComponent](wand: StyleWand[T]): int {.inline.} = wand.target.margin[1]
proc `marginTop=`*[T: WilllessComponent](wand: StyleWand[T], val: int) {.inline.} = wand.target.margin[1] = val

proc marginRight*[T: WilllessComponent](wand: StyleWand[T]): int {.inline.} = wand.target.margin[2]
proc `marginRight=`*[T: WilllessComponent](wand: StyleWand[T], val: int) {.inline.} = wand.target.margin[2] = val

proc marginBottom*[T: WilllessComponent](wand: StyleWand[T]): int {.inline.} = wand.target.margin[3]
proc `marginBottom=`*[T: WilllessComponent](wand: StyleWand[T], val: int) {.inline.} = wand.target.margin[3] = val


# Alignment & fill
proc orsum*[T: SomeInteger](a: openArray[T]): T = 
  if a.len == 0: return 0
  if a.len == 1: return a[0]
  result = a[0]
  for i in 1..a.high:
    result = result or a[i]


converter toSeq*[T: AlignStyle | FillStyle](s: T): seq[T] = @[s]
  

proc `align=`*[T: WilllessComponent](wand: StyleWand[T], val: seq[AlignStyle]) {.inline.} =
  wand.alignCache = orsum(map(val, ord))
  wand.target.layoutFlags = wand.alignCache or wand.fillCache

proc `fill=`*[T: WilllessComponent](wand: StyleWand[T], val: seq[FillStyle]) {.inline.} =
  wand.fillCache = orsum(map(val, ord))
  wand.target.layoutFlags = wand.alignCache or wand.fillCache

proc `align+=`*[T: WilllessComponent](wand: StyleWand[T], val: AlignStyle) {.inline.} =
  wand.target.layoutFlags = wand.target.layoutFlags or ord(val)

proc `fill+=`*[T: WilllessComponent](wand: StyleWand[T], val: FillStyle) {.inline.} =
  wand.target.layoutFlags = wand.target.layoutFlags or ord(val)

proc `alignFill=`*[T: WilllessComponent](wand: StyleWand[T], val: seq[AlignStyle | FillStyle]) {.inline.} =
  wand.target.layoutFlags = orsum(map(val, ord))

# Width & Height
proc width*[T: WilllessComponent](wand: StyleWand[T]): int {.inline.} = wand.target.width

proc `width=`*[T: WilllessComponent](wand: StyleWand[T], val: int) {.inline.} = wand.target.width = val

proc height*[T: WilllessComponent](wand: StyleWand[T]): int {.inline.} = wand.target.height

proc `height=`*[T: WilllessComponent](wand: StyleWand[T], val: int) {.inline.} = wand.target.height = val
