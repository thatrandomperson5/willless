import core, utils


type 
  Container* = ref object of InlineComponent
    children*: seq[InlineComponent]
  