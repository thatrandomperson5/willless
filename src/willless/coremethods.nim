

# Base methods

method render*(c: WilllessComponent) {.base.} = discard

method addChild*(c: WilllessComponent, child: WilllessComponent) {.base.} =
  raise ValueError.newException("Component doesn't have children.")

# Inline

method render*(c: InlineComponent) = discard
  
method write*(c: InlineComponent, x, y: int, s: string) {.base.} = c.subbuff.write(x, y, s, c.overflow)

method write*(c: InlineComponent, s: string) {.base.} = c.subbuff.write(s, c.overflow)

method fill*(c: InlineComponent, x1, y1, x2, y2: int, ch = ' ') {.base.} = 
  var f: string
  f.add ch
  c.subbuff.fill(x1, y1, x2, y2, f, c.overflow)


# Space

proc initSpaceComponent*(s: SpaceComponent, width, height: int, ch = ' ') =
  s.width = width
  s.height = height
  s.ch = ch

proc newSpace*(width, height: int, fill = ' '): SpaceComponent =
  new(result)
  result.initSpaceComponent(width, height, fill)
  
proc newEmpty*(): SpaceComponent {.inline.} = newSpace(0, 0)


method render*(s: SpaceComponent) =
  if s.height > 0 and s.width > 0:
    s.fill(0, 0, s.height-1, s.width-1, s.ch) # fill 