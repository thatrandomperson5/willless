import core, utils
import std/[wordwrap, strutils]
import buju

type 
  TextComponent* = ref object of InlineComponent
    text*: string
    wrap* = WrapStyle.Hard
    lineCache: seq[string] # A cache of lines 
    

proc initTextComponent*(t: TextComponent, text: string, wrap = WrapStyle.Hard) =
  t.text = text
  t.wrap = wrap
  t.layoutFlags = LayoutHorizontalFill

proc newText*(text: string, wrap = WrapStyle.Hard): TextComponent =
  new(result)
  result.initTextComponent(text, wrap)


proc textRender(t: TextComponent, width: int): seq[string] =

  var wrapped = t.text
  case t.wrap
  of Hard:
    wrapped = hardWrap(wrapped, width)
  of Soft:
    wrapped = wrapWords(wrapped, width)
  else:
    discard

  result = wrapped.splitLines()

method render*(t: TextComponent, l: var Layout) =
  for i, line in t.lineCache:
    t.write(0, i, line)

  t.lineCache.setLen(0)
  
method editLayout*(t: TextComponent, l: var Layout) =
  let precomp = l.computed(t.layoutNode)
  if t.layoutFlags == LayoutHorizontalFill:
    # Wrap to parent width
    let bounds = getSubBufferBounds(precomp) # Calculate
    t.lineCache = t.textRender(bounds.width) 
    t.height = t.lineCache.len

  elif t.layoutFlags == LayoutVerticalFill:
    discard # Not yet implemented vertical constraint wrap

  l.setSize(t.layoutNode, vec2(t.width.float, t.height.float))
