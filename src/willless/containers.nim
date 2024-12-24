import core, utils, styles
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


# Styles
import std/sequtils

type 
  ContainerDirection* = enum 
    ContainerFree = 0x00
    ContainerRow = LayoutBoxRow
    ContainerColumn = LayoutBoxColumn
  ContainerEffects* = enum
    ContainerEffectNone = 0x00
    ContainerWrap = LayoutBoxWrap
    ContainerAlignStart = LayoutBoxStart
    ContainerAlignEnd = LayoutBoxEnd
    ContainerJustify = LayoutBoxJustify


converter toSeq*[T: ContainerEffects | ContainerDirection](ce: T): seq[T] = @[ce]

proc `containerEffects=`*[T: Container](wand: StyleWand[T], val: seq[ContainerEffects]) {.inline.} =
  wand.target.boxFlags = wand.target.boxFlags or orsum(map(val, ord))

proc `containerDirection=`*[T: Container](wand: StyleWand[T], val: ContainerDirection) {.inline.} =
  wand.target.boxFlags = wand.target.boxFlags or ord(val)

proc containerEnableWrap*[T: Container](wand: StyleWand[T]) {.inline.} = 
  wand.target.boxFlags = wand.target.boxFlags or ord(ContainerWrap)

proc containerEnableJustify*[T: Container](wand: StyleWand[T]) {.inline.} = 
  wand.target.boxFlags = wand.target.boxFlags or ord(ContainerJustify)

proc `containerFlags=`*[T: Container](wand: StyleWand[T], val: seq[ContainerEffects | ContainerDirection]) {.inline.} =
  wand.target.boxFlags = orsum(map(val, ord))