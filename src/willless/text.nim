import core, utils
import std/wordwrap

type 
  TextComponent* = ref object of InlineComponent
    text*: string
    wrap* = WrapStyle.Hard
    

proc initTextComponent*(t: TextComponent, text: string, wrap = WrapStyle.Hard) =
  t.text = text
  t.wrap = wrap

proc newText*(text: string, wrap = WrapStyle.Hard): TextComponent =
  new(result)
  result.initTextComponent(text, wrap)


template textRender(): untyped =
  let buff = t.subbuff # Will be set by parent

  var wrapped = t.text
  case t.wrap
  of Hard:
    wrapped = hardWrap(wrapped, buff.width)
  of Soft:
    wrapped = wrapWords(wrapped, buff.width)
  else:
    discard

  t.write(wrapped)

method render*(t: TextComponent) =
  textRender()

