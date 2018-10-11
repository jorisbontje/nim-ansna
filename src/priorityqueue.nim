import options

import minmaxheap

type
  PriQueue*[T] = object
    queue*: MinMaxHeap[T]
    maxSize*: int

  PriFeedback*[T] = object
    added*: bool
    evicted*: bool
    evictedElem*: T

func initPriQueue*[T](maxSize: int): PriQueue[T] =
  result.queue = initMinMaxHeap[T]()
  result.maxSize = maxSize

proc add*[T](q: var PriQueue[T], elem: T): PriFeedback[T] =
  # first evict if necessary
  if q.queue.count >= q.maxSize:
    if elem < q.queue.min:
        #smaller than smallest
        return

    result.evicted = true
    result.evictedElem = q.queue.popMin()

  q.queue.push(elem)
  result.added = true

proc pop*[T](q: var PriQueue[T]): T =
  result = q.queue.popMax()

func count*[T](q: var PriQueue[T]): int =
  result = q.queue.buf.len

iterator items*[T](q: PriQueue[T]): T =
  for i in q.queue.buf.items():
    yield i

iterator mitems*[T](q: var PriQueue[T]): var T =
  for i in q.queue.buf.mitems():
    yield i

iterator pairs*[T](q: PriQueue[T]): tuple[key: int, val: T] =
  for key, val in q.queue.buf.pairs():
    yield (key, val)

func `[]`*[T](q: PriQueue[T], idx: int): T =
  q.queue.buf[idx]

proc `[]=`*[T](q: var PriQueue[T], idx: int, val: T): void =
  q.queue.buf[idx] = val
