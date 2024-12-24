import std/[macros]
import vmath


proc hardWrap*(s: string, length: int): string =
  var i = 0
  for idx, c in s:
    result.add c
    if c == '\n': 
      i = -1 # If newline reset 
   
    i += 1
    if (idx != s.high) and (i == length) and (s[idx+1] != '\n'): # If index not at end and line length and not already newline present
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


template computedToBuff*(v4: Vec4): array[4, int] {.deprecated.} = 
  ## See `newSubBufferFrom(Vec4, WilllessSubBuffer)`
  
  [v4[0].int, v4[1].int, v4[0].int + v4[2].int, v4[1].int + v4[3].int]


import std/math

proc roundInt*(f: SomeFloat, weightedDown: static bool = false): int {.inline.} =
  when weightedDown:
    if f > (floor(f) + 0.5):
      return int(ceil(f))
    return int(floor(f))
  else:
    return int(round(f))

proc getSubBufferBounds*(v4: Vec4): tuple[width, height: int, boundingBox: array[4, int]] =
  var boundingBox = [v4[0].roundInt(true), v4[1].roundInt(true), 0, 0]
  boundingBox[2] = roundInt(v4[0] + v4[2]) - 1 # rightmost
  boundingBox[3] = roundInt(v4[1] + v4[3]) - 1 # bottommost

  var width = (boundingBox[2] - boundingBox[0]) + 1
  var height = (boundingBox[3] - boundingBox[1]) + 1

  result = (width, height, boundingBox)
  
