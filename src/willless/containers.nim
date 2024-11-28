import core, utils
import std/tables


type 
  Container* = ref object of InlineComponent
    children*: seq[InlineComponent]



proc initContainer*(c: Container) = discard

proc newContainer*(): Container =
  new(result)
  result.initContainer()

method addChild*(c: Container, child: InlineComponent) =
  child.parent = c
  c.children.add child










































































