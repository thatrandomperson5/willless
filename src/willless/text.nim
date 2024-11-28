import core, utils
import std/[wordwrap, strutils]

type 
  TextComponent* = ref object of InlineComponent
    text*: string
    wrap* = WrapStyle.Hard
    lineCache: seq[string] # Internal line cache for efficency
    

proc initTextComponent*(t: TextComponent, text: string, wrap = WrapStyle.Hard) =
  t.text = text
  t.wrap = wrap

proc newText*(text: string, wrap = WrapStyle.Hard): TextComponent =
  new(result)
  result.initTextComponent(text, wrap)


proc textRender(t: TextComponent) =

  var wrapped = t.text
  case t.wrap
  of Hard:
    wrapped = hardWrap(wrapped, t.width)
  of Soft:
    wrapped = wrapWords(wrapped, t.width)
  else:
    discard

  t.lineCache = wrapped.splitLines()

method render*(t: TextComponent) =
  if t.lineCache.len == 0:
    t.width = t.subbuff.width
    textRender(t)
  for i, line in t.lineCache:
    t.write(0, i, line)
  
  t.lineCache.setLen(0)















