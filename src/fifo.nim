## A FIFO-like structure, that only supports put in and overwrites
## the oldest task when full

type
  FIFO*[T] = object
    queue: seq[T]
    maxSize: int

proc initFIFO*[T](maxSize: int): FIFO[T] =
  result.queue = newSeq[T]()
  result.maxSize = maxSize

proc add*[T](fifo: var FIFO[T], item: T): void =
  # TODO optimize using deques?
  fifo.queue.add(item)
  if fifo.queue.len > fifo.maxSize:
    fifo.queue.delete(0) # O(n)

proc delete*[T](fifo: var FIFO[T], idx: int): void =
   # O(n)
  fifo.queue.delete(idx)

proc len*[T](fifo: FIFO[T]): int =
  fifo.queue.len

proc high*[T](fifo: FIFO[T]): int =
  fifo.queue.high

proc `[]`*[T](fifo: var FIFO[T], idx: int): T =
  fifo.queue[idx]

proc `[]=`*[T](fifo: var FIFO[T], idx: int, val: T): void =
  fifo.queue[idx] = val

iterator pairs*[T](fifo: FIFO[T]): (int, T) =
  for key, val in fifo.queue.pairs:
    yield (key, val)
