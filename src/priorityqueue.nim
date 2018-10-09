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
  q.queue.push(elem)
  result.added = true

  if q.queue.count > q.maxSize:
    result.evicted = true
    result.evictedElem = q.queue.popMin()
    if result.evictedElem == elem:
      result.added = false

proc pop*[T](q: var PriQueue[T]): T =
  result = q.queue.popMax()

func count*[T](q: var PriQueue[T]): int =
  result = q.queue.buf.len

iterator items*[T](q: PriQueue[T]): T =
  for i in q.queue.buf.items():
    yield i
