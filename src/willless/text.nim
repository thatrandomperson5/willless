import core, utils
import std/wordwrap

type 
  TextComponent* = ref object of InlineComponent
    text*: string
    wrap* = WrapStyle.Hard

  ExpandingText* = ref object of ExpandingComponent
    text*: string
    wrap* = WrapStyle.Hard
    

proc initTextComponent*(t: TextComponent, text: string, wrap = WrapStyle.Hard) =
  t.text = text
  t.wrap = wrap

proc initExpandingText*(t: ExpandingText, text: string, wrap = WrapStyle.Hard) =
  t.initExpandingComponent()
  t.text = text
  t.wrap = wrap

proc newText*(text: string, wrap = WrapStyle.Hard): TextComponent =
  new(result)
  result.initTextComponent(text, wrap)


proc newExpandingText*(text: string, wrap = WrapStyle.Hard): ExpandingText =
  new(result)
  result.initExpandingText(text, wrap)


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

method render*(t: ExpandingText) =
  render(super(t))
  textRender()
