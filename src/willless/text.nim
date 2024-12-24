import core, utils
import std/[wordwrap, strutils]
import buju

type 
  TextComponent* = ref object of InlineComponent
    text*: string
    wrap* = WrapStyle.Hard
    cache: string # A cached version of the wrapped string
    

proc initTextComponent*(t: TextComponent, text: string, wrap = WrapStyle.Hard) =
  t.text = text
  t.wrap = wrap
  t.layoutFlags = LayoutHorizontalFill

proc newText*(text: string, wrap = WrapStyle.Hard): TextComponent =
  new(result)
  result.initTextComponent(text, wrap)


proc textRender(t: TextComponent, width: int): string =

  result = t.text
  case t.wrap
  of Hard:
    result = hardWrap(result, width)
  of Soft:
    result = wrapWords(result, width)
  else:
    discard


method render*(t: TextComponent, l: var Layout) =
  t.write(t.cache)

  t.cache = ""
  
method editLayout*(t: TextComponent, l: var Layout) =
  let precomp = l.computed(t.layoutNode)
  if t.layoutFlags == LayoutHorizontalFill:
    # Wrap to parent width
    let bounds = getSubBufferBounds(precomp) # Calculate
    t.cache = t.textRender(bounds.width) 
    t.height = t.cache.count("\n") + 1 # + 1 for the first line

  elif t.layoutFlags == LayoutVerticalFill:
    discard # Not yet implemented vertical constraint wrap

  l.setSize(t.layoutNode, vec2(t.width.float, t.height.float))
