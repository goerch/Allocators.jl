# Allocators.jl

## Rationale

Complex data structures with immutable nodes generate considerable memory
pressure. Here we evaluate if custom allocation schemes can alleviate the
problem.

## Design

We provide 2 allocator classes `Allocator` and `FreeListAllocator` classes with
a similar interface:

- `getindex(alloc, i)`
- `setindex!(alloc, t, i)`
- `allocateend!(alloc)`
- `allocatebegin!(alloc)`
- `deallocateend!(alloc)`
- `deallocatebegin!(alloc)`
- `deallocate!(alloc, i])`
- `isempty(alloc)`
- `emptyend!`
- `emptybegin!`

Both allocators can be instantiated to be fixed size or resizable.
`FreeListAllocator` additionally keeps an internal free list to reuse memory.

## Tests

We test the allocators against basic data structures.

- List, see example/list.jl
- Stack, see example/stack.jl
- Queue, see example/queue.jl
- Tree, see example/tree.jl

## Results

Tested on Julia 1.6.3

### Lists

```
10 runs with 100000 elements
 payload of 1 float(s)
  without allocator               6.669 ms (1000000 allocations: 30.52 MiB)
  fixed allocator                 2.746 ms (0 allocations: 0 bytes)
  resizable allocator             2.765 ms (0 allocations: 0 bytes)
  fixed free list allocator       2.936 ms (0 allocations: 0 bytes)
  resizable free list allocator   3.068 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  without allocator               22.653 ms (1000000 allocations: 106.81 MiB)
  fixed allocator                 7.164 ms (0 allocations: 0 bytes)
  resizable allocator             7.181 ms (0 allocations: 0 bytes)
  fixed free list allocator       9.069 ms (0 allocations: 0 bytes)
  resizable free list allocator   10.444 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  without allocator               362.510 ms (1000000 allocations: 854.49 MiB)
  fixed allocator                 72.884 ms (0 allocations: 0 bytes)
  resizable allocator             73.211 ms (0 allocations: 0 bytes)
  fixed free list allocator       90.060 ms (0 allocations: 0 bytes)
  resizable free list allocator   91.831 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  without allocator               5.032 ms (1000000 allocations: 30.52 MiB)
  fixed allocator                 1.791 ms (0 allocations: 0 bytes)
  resizable allocator             2.138 ms (0 allocations: 0 bytes)
  fixed free list allocator       2.672 ms (0 allocations: 0 bytes)
  resizable free list allocator   2.807 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  without allocator               29.117 ms (1000000 allocations: 106.81 MiB)
  fixed allocator                 2.656 ms (0 allocations: 0 bytes)
  resizable allocator             2.760 ms (0 allocations: 0 bytes)
  fixed free list allocator       5.720 ms (0 allocations: 0 bytes)
  resizable free list allocator   5.781 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  without allocator               367.239 ms (1000000 allocations: 854.49 MiB)
  fixed allocator                 14.699 ms (0 allocations: 0 bytes)
  resizable allocator             13.861 ms (0 allocations: 0 bytes)
  fixed free list allocator       45.158 ms (0 allocations: 0 bytes)
  resizable free list allocator   47.700 ms (0 allocations: 0 bytes)
```

There is a performance win depending on the payload when compared to the
naive implementation. 

### Stacks

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Stack   3.302 ms (1943 allocations: 15.35 MiB)
  fixed allocator        2.390 ms (0 allocations: 0 bytes)
  resizable allocator    2.576 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack   13.302 ms (2914 allocations: 83.58 MiB)
  fixed allocator        4.416 ms (0 allocations: 0 bytes)
  resizable allocator    4.605 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack   216.070 ms (2914 allocations: 766.31 MiB)
  fixed allocator        61.116 ms (0 allocations: 0 bytes)
  resizable allocator    56.000 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Stack   2.611 ms (3 allocations: 16.23 KiB)
  fixed allocator        2.462 ms (0 allocations: 0 bytes)
  resizable allocator    2.753 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack   5.419 ms (4 allocations: 88.19 KiB)
  fixed allocator        2.724 ms (0 allocations: 0 bytes)
  resizable allocator    3.215 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack   50.075 ms (4 allocations: 808.19 KiB)
  fixed allocator        17.558 ms (0 allocations: 0 bytes)
  resizable allocator    13.688 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's stack shows a performance win depending on
size of elements and size of the queue.

### Queues

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Queue            3.904 ms (1943 allocations: 15.35 MiB)
  fixed allocator                 2.418 ms (0 allocations: 0 bytes)
  resizable allocator             2.952 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue            21.616 ms (2914 allocations: 83.58 MiB)
  fixed allocator                 5.047 ms (0 allocations: 0 bytes)
  resizable allocator             10.739 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue            257.929 ms (2914 allocations: 766.31 MiB)
  fixed allocator                 55.361 ms (0 allocations: 0 bytes)
  resizable allocator             69.567 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Queue            2.732 ms (3 allocations: 16.23 KiB)
  fixed allocator                 2.036 ms (0 allocations: 0 bytes)
  resizable allocator             2.694 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue            5.697 ms (4 allocations: 88.19 KiB)
  fixed allocator                 2.477 ms (0 allocations: 0 bytes)
  resizable allocator             3.103 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue            43.910 ms (4 allocations: 808.19 KiB)
  fixed allocator                 13.371 ms (0 allocations: 0 bytes)
  resizable allocator             14.442 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's queue shows a performance win depending on
size of elements and size of the queue.

### Trees

```
10 runs with 100000 elements
  DataStructures.SortedSet        203.639 ms (85 allocations: 14.53 MiB)
  without allocator               703.802 ms (1000000 allocations: 45.78 MiB)
  fixed allocator                 235.946 ms (0 allocations: 0 bytes)
  resizable allocator             235.416 ms (0 allocations: 0 bytes)
  fixed free list allocator       252.612 ms (0 allocations: 0 bytes)
  resizable free list allocator   272.337 ms (0 allocations: 0 bytes)
1000 runs with 1000 elements
  DataStructures.SortedSet        130.573 ms (50 allocations: 162.41 KiB)
  without allocator               517.433 ms (1000000 allocations: 45.78 MiB)
  fixed allocator                 116.865 ms (0 allocations: 0 bytes)
  resizable allocator             112.303 ms (0 allocations: 0 bytes)
  fixed free list allocator       127.600 ms (0 allocations: 0 bytes)
  resizable free list allocator   125.375 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
  DataStructures.SortedSet        68.548 ms (24 allocations: 3.34 KiB)
  without allocator               206.668 ms (1000000 allocations: 45.78 MiB)
  fixed allocator                 34.382 ms (0 allocations: 0 bytes)
  resizable allocator             34.018 ms (0 allocations: 0 bytes)
  fixed free list allocator       38.367 ms (0 allocations: 0 bytes)
  resizable free list allocator   38.290 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's sorted set shows a small performance win
for small trees.
