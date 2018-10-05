## double heap (min and max) base on
## Min-Max Heaps and Generalized Priority Queues
## M. D. ATKINSON,J.-R. SACK, N. SANTORO,and T. STROTHOTTE
## http://cglab.ca/~morin/teaching/5408/refs/minmax.pdf
##
## root is level 0
## even level are min levels, odd are max level;
## all descendent of a min level element a are bigger than a
## all descendent of a max level element a are smaller than a
## invert means check > instead of < allows to use same function for min and max levels.

## Ported from
## https://github.com/quxiaofeng/python-stl/blob/master/meshlab/MeshLabSrc_AllInc_v132/meshlab/src/plugins_experimental/edit_ocme/src/cache/old/mmheap.h

type
  MinMaxHeap*[T] = object
    buf*: seq[T]

# PRIVATE

func level(n: int): int =
  var n = n
  result = -1
  while n > 0:
    n = n shr 1
    result += 1

func isOnMaxLevel(i: int): bool {.inline.} =
  result = bool(level(i + 1) and 1) # % 2

func parent(i: int): int {.inline.} =
  result = ((i + 1) div 2) - 1
func grandparent(i: int): int {.inline.} =
  result = ((i + 1) div 4) - 1
func leftChild(i: int): int {.inline.} =
  result = 2 * i + 1
func leftGranChild(i : int): int {.inline.} =
  result = 4 * i + 3

proc swap[T](q: var MinMaxHeap[T], a, b: int): void {.inline.} =
  let tmp = q.buf[a]
  q.buf[a] = q.buf[b]
  q.buf[b] = tmp

func smallestChild[T](q: MinMaxHeap[T], i: int, invert: bool): int =
  # return smallest of children or self if no children
  let l = leftChild(i)
  if l >= q.buf.len:
    return i # no children, return self

  let r = l + 1 # right child
  if r < q.buf.len:
    let lv = q.buf[l]
    let rv = q.buf[r]
    if (rv < lv) xor invert:
      return r
  return l

func smallestGrandChild[T](q: MinMaxHeap[T], i: int, invert: bool): int =
  # return smallest of grandchildren or self if no children
  let l = leftGranChild(i)
  if l >= q.buf.len:
    return i
  var lv = q.buf[l]
  result = l
  var r = l + 1
  while r < q.buf.len and r < l + 4:
    # iterate on three grandsiblings (they are consecutive)
    let rv = q.buf[r]
    if (rv < lv) xor invert:
      lv = rv
      result = r
    r += 1

proc trickleDown[T](q: var MinMaxHeap[T], i: int, invert: bool): void =
  var i = i
  # assert invert == isOnMaxLevel(i)
  while true:
    # enforce min-max property on level(i), we need to check children and grandchildren
    let m = q.smallestChild(i, invert)
    if m == i:
      break # no children
    if (q.buf[m] < q.buf[i]) xor invert:
      # swap children, max property on level(i)+1 automatically enforced
      q.swap(i, m)

    let j = q.smallestGrandChild(i, invert)
    if j == i:
      break # no grandchildren
    if (q.buf[j] < q.buf[i]) xor invert:
      q.swap(i, j)
      i = j # we need to enforce min-max property on level(j) now.
    else:
      break # no swap, finish

proc bubbleUp[T](q: var MinMaxHeap[T], i: int): void =
  var i = i
  let m = parent(i)
  var invert = isOnMaxLevel(i)
  if m >= 0 and ((q.buf[i] > q.buf[m]) xor invert):
    q.swap(i, m)
    i = m
    invert = not invert

  var gm = grandparent(i)
  while gm >= 0 and ((q.buf[i] < q.buf[gm]) xor invert):
    q.swap(i, gm)
    i = gm
    gm = grandparent(i)

# PUBLIC

proc initMinMaxHeap*[T](initialSize: int = 4): MinMaxHeap[T] =
  result.buf.newSeq(initialSize)
  result.buf.setLen(0)

func count*[T](q: MinMaxHeap[T]): int =
  result = q.buf.len

proc push*[T](q: var MinMaxHeap[T], elem: T): void =
  q.buf.add(elem)
  q.bubbleUp(q.buf.len-1)

func min*[T](q: MinMaxHeap[T]): T =
  # root is smaller element
  result = q.buf[0]

proc popMin*[T](q: var MinMaxHeap[T]): T =
  result = q.buf[0]
  q.buf[0] = q.buf[q.buf.high]
  q.buf.del(q.buf.high)
  q.trickleDown(0, false) # enforce minmax heap property

func max*[T](q: MinMaxHeap[T]): T =
  # max is biggest of the two children of root (or root if no children)
  result = q.buf[q.smallestChild(0, true)]

proc popMax*[T](q: var MinMaxHeap[T]): T =
  let p = q.smallestChild(0, true)
  result = q.buf[p]
  q.buf[p] = q.buf[q.buf.high] # max is replaced with last item.
  q.buf.del(q.buf.high)
  q.trickleDown(p, true) # enforce minmax heap property

proc rebuild*[T](q: var MinMaxHeap[T]): void =
  # just reinsert all elements, (no push back necessary, of course)
  for i in 0..<q.buf.len:
    q.bubbleUp(i)
