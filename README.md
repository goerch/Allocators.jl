# Allocators.jl

## Rationale

Complex data structures with immutable nodes generate considerable memory
pressure. Here we evaluate if custom allocation schemes can alleviate the
problem.

## Design

We provide 4 allocator classes `Allocator`, `FreeListAllocator`, `SOAllocator`
and `FreeListSOAllocator` with a similar interface:

- `getindex(alloc, i)`
- `setindex!(alloc, t, i)`
- `setindex!(alloc, i, t, j)`
- `allocateend!(alloc)`
- `allocatebegin!(alloc)`
- `deallocateend!(alloc)`
- `deallocatebegin!(alloc)`
- `deallocate!(alloc, i])`
- `isempty(alloc)`
- `emptyend!`
- `emptybegin!`

All allocators can be instantiated to be fixed size or resizable.
`FreeListAllocator`, `FreeListSOAllocator` additionally keep an internal free
list to reuse memory .`SOAllocator` and `FreeListSOAllocator`  apply a simple
[SOA transform](https://en.wikipedia.org/wiki/AoS_and_SoA).

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
  DataStructures.List                      333.095 ms (3994910 allocations: 91.47 MiB)
  List without allocator                   6.727 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                     2.982 ms (0 allocations: 0 bytes)
  with resizable allocator                 3.010 ms (0 allocations: 0 bytes)
  with fixed free list allocator           3.833 ms (0 allocations: 0 bytes)
  with resizable free list allocator       3.384 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 2.521 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             2.678 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       6.579 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   6.687 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                      342.849 ms (3994910 allocations: 152.51 MiB)
  List without allocator                   24.333 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                     6.877 ms (0 allocations: 0 bytes)
  with resizable allocator                 6.816 ms (0 allocations: 0 bytes)
  with fixed free list allocator           10.389 ms (0 allocations: 0 bytes)
  with resizable free list allocator       10.087 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 5.378 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             4.856 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       10.330 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   10.538 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                      739.093 ms (3994910 allocations: 839.16 MiB)
  List without allocator                   317.263 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                     71.614 ms (0 allocations: 0 bytes)
  with resizable allocator                 71.632 ms (0 allocations: 0 bytes)
  with fixed free list allocator           86.552 ms (0 allocations: 0 bytes)
  with resizable free list allocator       86.517 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 55.635 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             55.387 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       68.209 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   71.920 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.List                      364.245 ms (2200000 allocations: 63.32 MiB)
  List without allocator                   5.364 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                     2.119 ms (0 allocations: 0 bytes)
  with resizable allocator                 2.357 ms (0 allocations: 0 bytes)
  with fixed free list allocator           3.129 ms (0 allocations: 0 bytes)
  with resizable free list allocator       3.337 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 2.275 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             2.934 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       7.292 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   7.812 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                      399.727 ms (2200000 allocations: 124.36 MiB)
  List without allocator                   34.460 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                     3.236 ms (0 allocations: 0 bytes)
  with resizable allocator                 3.457 ms (0 allocations: 0 bytes)
  with fixed free list allocator           7.806 ms (0 allocations: 0 bytes)
  with resizable free list allocator       7.862 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 3.187 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             3.692 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       8.945 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   8.876 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                      747.354 ms (2200000 allocations: 811.00 MiB)
  List without allocator                   334.645 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                     15.659 ms (0 allocations: 0 bytes)
  with resizable allocator                 14.943 ms (0 allocations: 0 bytes)
  with fixed free list allocator           46.761 ms (0 allocations: 0 bytes)
  with resizable free list allocator       46.028 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 16.666 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             16.550 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       35.618 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   35.635 ms (0 allocations: 0 bytes)
```

DataStructures.jl's list seems slightly broken. There is a performance gain
 depending on the payload when compared to the allocatorless implementation.

### Stacks

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Stack             6.758 ms (1943 allocations: 15.35 MiB)
  Stack with fixed allocator       2.786 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   2.794 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             27.867 ms (2914 allocations: 83.58 MiB)
  Stack with fixed allocator       5.406 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   5.440 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             258.382 ms (2914 allocations: 766.31 MiB)
  Stack with fixed allocator       60.379 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   61.938 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Stack             2.996 ms (3 allocations: 16.23 KiB)
  Stack with fixed allocator       2.800 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   2.730 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             5.392 ms (4 allocations: 88.19 KiB)
  Stack with fixed allocator       2.704 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   3.391 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             43.572 ms (4 allocations: 808.19 KiB)
  Stack with fixed allocator       14.028 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   14.690 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's stack shows a performance gain depending on
size of elements and size of the queue.

### Queues

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Queue             6.399 ms (1943 allocations: 15.35 MiB)
  Queue with fixed allocator       2.266 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   2.793 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             48.307 ms (2914 allocations: 83.58 MiB)
  Queue with fixed allocator       5.711 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   10.882 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             282.942 ms (2914 allocations: 766.31 MiB)
  Queue with fixed allocator       56.276 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   71.449 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Queue             2.708 ms (3 allocations: 16.23 KiB)
  Queue with fixed allocator       1.905 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   2.390 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             5.701 ms (4 allocations: 88.19 KiB)
  Queue with fixed allocator       2.879 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   3.519 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             43.998 ms (4 allocations: 808.19 KiB)
  Queue with fixed allocator       16.092 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   13.890 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's queue shows a performance gain depending on
size of elements and size of the queue.

### Trees

```
10 runs with 100000 elements
  DataStructures.AVLTree                   45.753 s (71025181 allocations: 1.12 GiB)
  DataStructures.RBTree                    3.817 s (2000002 allocations: 122.07 MiB)
  AVLTrees.AVLSet                          1.059 s (2000001 allocations: 91.55 MiB)
  Tree without allocator                   1.188 s (2000000 allocations: 91.55 MiB)
  with fixed allocator                     977.884 ms (0 allocations: 0 bytes)
  with resizable allocator                 976.628 ms (0 allocations: 0 bytes)
  with fixed free list allocator           945.763 ms (0 allocations: 0 bytes)
  with resizable free list allocator       985.432 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 1.183 s (0 allocations: 0 bytes)
  with resizable SOA allocator             1.114 s (0 allocations: 0 bytes)
  with fixed free list SOA allocator       1.062 s (0 allocations: 0 bytes)
  with resizable free list SOA allocator   1.103 s (0 allocations: 0 bytes)
1000 runs with 1000 elements
  DataStructures.AVLTree                   29.251 s (28635001 allocations: 497.97 MiB)
  DataStructures.RBTree                    3.540 s (2000002 allocations: 122.07 MiB)
  AVLTrees.AVLSet                          1.128 s (2000001 allocations: 91.55 MiB)
  Tree without allocator                   754.092 ms (2000000 allocations: 91.55 MiB)
  with fixed allocator                     410.078 ms (0 allocations: 0 bytes)
  with resizable allocator                 411.927 ms (0 allocations: 0 bytes)
  with fixed free list allocator           437.995 ms (0 allocations: 0 bytes)
  with resizable free list allocator       438.718 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 538.092 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             526.565 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       538.003 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   539.919 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
  DataStructures.AVLTree                   11.649 s (10000001 allocations: 213.62 MiB)
  DataStructures.RBTree                    3.408 s (2000002 allocations: 122.07 MiB)
  AVLTrees.AVLSet                          1.114 s (2000001 allocations: 91.55 MiB)
  Tree without allocator                   409.117 ms (2000000 allocations: 91.55 MiB)
  with fixed allocator                     134.250 ms (0 allocations: 0 bytes)
  with resizable allocator                 135.006 ms (0 allocations: 0 bytes)
  with fixed free list allocator           149.336 ms (0 allocations: 0 bytes)
  with resizable free list allocator       143.892 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 208.557 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             211.363 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       215.124 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   218.221 ms (0 allocations: 0 bytes)
```

DataStructures.jl's `AVLTree` seems slightly broken. Comparison with
DataStructures.jl's `RBTree` and AVLTrees.jl's `AVLSet` shows some performance
gain.
