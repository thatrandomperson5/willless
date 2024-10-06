import std/macros


proc hardWrap*(s: string, length: int): string =
  var i = 0
  for c in s:
    result.add c # Add char
    if c == '\n': i = 0 # If newline reset
    i += 1 
    if i == length:
      result.add '\n'
      i = 0


proc findKind(n: NimNode, k: NimNodeKind): (NimNode, bool) =
  # echo n.treeRepr
  for child in n:
    if child.kind == k:
      return (child, true)
    elif child.len > 0:
      let r = findKind(child, k)
      if r[1]:
        return r
  
  result[1] = false



macro super*(t: typed): untyped =
  t.expectKind(nnkSym)
  var impl = getTypeImpl(t)
  if impl.kind == nnkRefTy:
    impl = getTypeImpl(impl[0])
  let parent = findKind(impl, nnkOfInherit)[0][0]
  
  result = newCall(parent, t)
  # echo result.repr