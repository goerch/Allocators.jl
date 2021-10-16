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
  DataStructures.List                      395.142 ms (3994910 allocations: 91.47 MiB)
  List without allocator                   7.942 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                     3.367 ms (0 allocations: 0 bytes)
  with resizable allocator                 3.587 ms (0 allocations: 0 bytes)
  with fixed free list allocator           4.128 ms (0 allocations: 0 bytes)
  with resizable free list allocator       4.200 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 3.025 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             3.249 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       8.429 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   8.081 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                      438.855 ms (3994910 allocations: 152.51 MiB)
  List without allocator                   40.776 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                     8.998 ms (0 allocations: 0 bytes)
  with resizable allocator                 8.676 ms (0 allocations: 0 bytes)
  with fixed free list allocator           12.764 ms (0 allocations: 0 bytes)
  with resizable free list allocator       12.735 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 6.127 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             5.731 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       12.512 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   14.027 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                      956.524 ms (3994910 allocations: 839.16 MiB)
  List without allocator                   442.167 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                     83.345 ms (0 allocations: 0 bytes)
  with resizable allocator                 75.376 ms (0 allocations: 0 bytes)
  with fixed free list allocator           98.112 ms (0 allocations: 0 bytes)
  with resizable free list allocator       88.990 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 56.665 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             56.830 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       68.195 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   73.258 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.List                      391.495 ms (2200000 allocations: 63.32 MiB)
  List without allocator                   5.851 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                     2.408 ms (0 allocations: 0 bytes)
  with resizable allocator                 2.850 ms (0 allocations: 0 bytes)
  with fixed free list allocator           3.756 ms (0 allocations: 0 bytes)
  with resizable free list allocator       4.005 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 2.745 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             3.119 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       7.671 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   7.878 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                      411.165 ms (2200000 allocations: 124.36 MiB)
  List without allocator                   41.876 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                     3.433 ms (0 allocations: 0 bytes)
  with resizable allocator                 3.805 ms (0 allocations: 0 bytes)
  with fixed free list allocator           8.192 ms (0 allocations: 0 bytes)
  with resizable free list allocator       7.834 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 5.084 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             3.849 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       8.867 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   8.423 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                      782.531 ms (2200000 allocations: 811.00 MiB)
  List without allocator                   319.802 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                     17.639 ms (0 allocations: 0 bytes)
  with resizable allocator                 15.927 ms (0 allocations: 0 bytes)
  with fixed free list allocator           46.228 ms (0 allocations: 0 bytes)
  with resizable free list allocator       46.666 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 14.661 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             14.851 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       33.553 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   31.459 ms (0 allocations: 0 bytes)
```

DataStructures.jl's list seems slightly broken. There is a performance gain
 depending on the payload when compared to the allocatorless implementation.

### Stacks

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Stack             3.458 ms (1943 allocations: 15.35 MiB)
  Stack with fixed allocator       2.588 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   2.853 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             14.864 ms (2914 allocations: 83.58 MiB)
  Stack with fixed allocator       6.011 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   5.703 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             227.075 ms (2914 allocations: 766.31 MiB)
  Stack with fixed allocator       67.305 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   69.272 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Stack             3.389 ms (3 allocations: 16.23 KiB)
  Stack with fixed allocator       2.596 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   2.929 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             5.438 ms (4 allocations: 88.19 KiB)
  Stack with fixed allocator       3.505 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   4.035 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             52.534 ms (4 allocations: 808.19 KiB)
  Stack with fixed allocator       19.233 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   21.224 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's stack shows a performance gain depending on
size of elements and size of the queue.

### Queues

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Queue             3.735 ms (1943 allocations: 15.35 MiB)
  Queue with fixed allocator       2.797 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   3.444 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             14.084 ms (2914 allocations: 83.58 MiB)
  Queue with fixed allocator       6.553 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   11.466 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             229.751 ms (2914 allocations: 766.31 MiB)
  Queue with fixed allocator       60.659 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   74.317 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Queue             2.814 ms (3 allocations: 16.23 KiB)
  Queue with fixed allocator       2.571 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   3.468 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             6.072 ms (4 allocations: 88.19 KiB)
  Queue with fixed allocator       3.029 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   3.446 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             47.971 ms (4 allocations: 808.19 KiB)
  Queue with fixed allocator       17.007 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   17.524 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's queue shows a performance gain depending on
size of elements and size of the queue.

### Trees

```
10 runs with 100000 elements
  DataStructures.AVLTree                   46.413 s (71025181 allocations: 1.12 GiB)
  DataStructures.RBTree                    3.981 s (2000002 allocations: 122.07 MiB)
  AVLTrees.AVLSet                          2.297 s (2000001 allocations: 91.55 MiB)
  Tree without allocator                   1.229 s (2000000 allocations: 91.55 MiB)
  with fixed allocator                     1.010 s (0 allocations: 0 bytes)
  with resizable allocator                 978.232 ms (0 allocations: 0 bytes)
  with fixed free list allocator           952.236 ms (0 allocations: 0 bytes)
  with resizable free list allocator       955.698 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 1.941 s (0 allocations: 0 bytes)
  with resizable SOA allocator             2.036 s (0 allocations: 0 bytes)
  with fixed free list SOA allocator       1.935 s (0 allocations: 0 bytes)
  with resizable free list SOA allocator   1.985 s (0 allocations: 0 bytes)
1000 runs with 1000 elements
  DataStructures.AVLTree                   29.232 s (28635001 allocations: 497.97 MiB)
  DataStructures.RBTree                    3.428 s (2000002 allocations: 122.07 MiB)
  AVLTrees.AVLSet                          2.193 s (2000001 allocations: 91.55 MiB)
  Tree without allocator                   802.193 ms (2000000 allocations: 91.55 MiB)
  with fixed allocator                     425.244 ms (0 allocations: 0 bytes)
  with resizable allocator                 430.223 ms (0 allocations: 0 bytes)
  with fixed free list allocator           445.841 ms (0 allocations: 0 bytes)
  with resizable free list allocator       452.787 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 1.140 s (0 allocations: 0 bytes)
  with resizable SOA allocator             1.112 s (0 allocations: 0 bytes)
  with fixed free list SOA allocator       1.242 s (0 allocations: 0 bytes)
  with resizable free list SOA allocator   1.202 s (0 allocations: 0 bytes)
100000 runs with 10 elements
  DataStructures.AVLTree                   10.862 s (10000001 allocations: 213.62 MiB)
  DataStructures.RBTree                    2.993 s (2000002 allocations: 122.07 MiB)
  AVLTrees.AVLSet                          2.147 s (2000001 allocations: 91.55 MiB)
  Tree without allocator                   384.207 ms (2000000 allocations: 91.55 MiB)
  with fixed allocator                     131.773 ms (0 allocations: 0 bytes)
  with resizable allocator                 131.995 ms (0 allocations: 0 bytes)
  with fixed free list allocator           142.834 ms (0 allocations: 0 bytes)
  with resizable free list allocator       143.267 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 455.844 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             454.490 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       491.332 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   495.931 ms (0 allocations: 0 bytes)
```

DataStructures.jl's `AVLTree` seems slightly broken. Comparison with
DataStructures.jl's `RBTree` and AVLTrees.jl's `AVLSet` shows some performance
gain.
