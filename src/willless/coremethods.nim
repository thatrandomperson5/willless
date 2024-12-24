

# Base methods

method render*(c: WilllessComponent, l: var Layout) {.base.} = discard

method addChild*(c: WilllessComponent, child: WilllessComponent) {.base.} =
  raise ValueError.newException("Component doesn't have children.")


method makeLayout*(c: WilllessComponent, l: var Layout) {.base.} = 
  c.layoutNode = l.node()
  l.setLayoutFlags(c.layoutNode, c.layoutFlags)
  l.setSize(c.layoutNode, vec2(c.width.float, c.height.float))
  l.setMargin(c.layoutNode, vec4(c.margin[0].float, c.margin[1].float, c.margin[2].float, c.margin[3].float))

method editLayout*(c: WilllessComponent, l: var Layout) {.base.} = discard

# Inline

proc usesSpace*(c: InlineComponent): bool {.inline.} = c.subbuff.width > 0 and c.subbuff.height > 0

method render*(c: InlineComponent, l: var Layout) = discard
  
method write*(c: InlineComponent, x, y: int, s: string) {.base.} = c.subbuff.write(x, y, s, c.overflow)

method write*(c: InlineComponent, s: string) {.base.} = c.subbuff.write(s, c.overflow)

method fill*(c: InlineComponent, x1, y1, x2, y2: int, ch = ' ') {.base.} = 
  var f: string
  f.add ch
  c.subbuff.fill(x1, y1, x2, y2, f, c.overflow)

method drawRect*(c: InlineComponent, x1, y1, x2, y2: int, doubleStyle = false) {.base.} = c.subbuff.drawRect(x1, y1, x2, y2, doubleStyle)



# method addChild*(c: InlineComponent, child: InlineComponent) {.base.} = discard


# Space

proc initSpaceComponent*(s: SpaceComponent, width, height: int, ch = ' ') =
  s.width = width
  s.height = height
  s.ch = ch

proc newSpace*(width, height: int, fill = ' '): SpaceComponent =
  new(result)
  result.initSpaceComponent(width, height, fill)
  
proc newEmpty*(): SpaceComponent {.inline.} = newSpace(0, 0)


method render*(s: SpaceComponent, l: var Layout) =
  if s.height > 0 and s.width > 0:
    s.fill(0, 0, s.width-1, s.height-1, s.ch) # fill 


# FlexibleComponent
#[ Deprecated

proc initExpandingComponent*(f: ExpandingComponent, expansion=ExpansionStyle.XY,
  minWidth, minHeight, maxWidth, maxHeight = 0) =
    f.expansion = expansion
    f.minWidth = minWidth
    f.minHeight = minHeight
    f.maxWidth = maxWidth
    f.maxHeight = maxHeight

    if f.maxWidth == 0: f.maxWidth = high(int) # infinity
    if f.maxHeight == 0: f.maxHeight = high(int) # infintiy


method addChild*(f: ExpandingComponent, child: InlineComponent) =
  child.parent = f
  f.child = child

method render*(f: ExpandingComponent) =
  doAssert f.subbuff.height <= f.maxHeight and f.subbuff.height >= f.minHeight
  doAssert f.subbuff.width <= f.maxWidth and f.subbuff.width >= f.minWidth 
  
  f.child.subbuff = f.subbuff # This type is only a denotation of a more advanced sizing protocol
  f.child.render()
  
]#