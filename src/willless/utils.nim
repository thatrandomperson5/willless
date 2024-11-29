import std/[macros]
import vmath


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



macro super*(t: typed, run: untyped): untyped =
  t.expectKind(nnkSym)
  var impl = getTypeImpl(t)
  if impl.kind == nnkRefTy:
    impl = getTypeImpl(impl[0])
  let parent = findKind(impl, nnkOfInherit)[0][0]

  run.expectKind({nnkCall, nnkStmtList})
  var runProc = run
  if runProc.kind != nnkCall:
    runProc = run[0]
    runProc.expectKind(nnkCall)

  runProc.insert(1, newCall(parent, t))
  
  result = newTree(nnkCommand, newIdentNode("procCall"), runProc)
  # echo result.repr


template computedToBuff*(v4: Vec4): array[4, int] = 
  [v4[0].int, v4[1].int, v4[0].int + v4[2].int, v4[1].int + v4[3].int]