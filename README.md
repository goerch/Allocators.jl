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
100000 elements
 payload of 1 float(s)
  DataStructures.List                      29.576 ms (399492 allocations: 9.15 MiB)
  List without allocator                   651.500 μs (100001 allocations: 3.05 MiB)
  with fixed allocator                     298.100 μs (1 allocation: 16 bytes)
  with resizable allocator                 297.700 μs (1 allocation: 16 bytes)
  with fixed free list allocator           342.500 μs (1 allocation: 16 bytes)
  with resizable free list allocator       346.700 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 263.100 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             283.100 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       626.600 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   646.000 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.List                      30.605 ms (399492 allocations: 15.25 MiB)
  List without allocator                   2.118 ms (100001 allocations: 10.68 MiB)
  with fixed allocator                     668.700 μs (1 allocation: 16 bytes)
  with resizable allocator                 681.300 μs (1 allocation: 16 bytes)
  with fixed free list allocator           951.500 μs (1 allocation: 16 bytes)
  with resizable free list allocator       960.400 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 565.300 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             553.700 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       961.700 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   1.052 ms (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.List                      64.710 ms (399492 allocations: 83.92 MiB)
  List without allocator                   23.897 ms (100001 allocations: 85.45 MiB)
  with fixed allocator                     6.986 ms (1 allocation: 16 bytes)
  with resizable allocator                 7.026 ms (1 allocation: 16 bytes)
  with fixed free list allocator           8.485 ms (1 allocation: 16 bytes)
  with resizable free list allocator       8.497 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 5.447 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             5.423 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       6.661 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   6.810 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  DataStructures.List                      3.138 μs (23 allocations: 680 bytes)
  List without allocator                   68.814 ns (11 allocations: 336 bytes)
  with fixed allocator                     34.743 ns (1 allocation: 16 bytes)
  with resizable allocator                 37.059 ns (1 allocation: 16 bytes)
  with fixed free list allocator           49.240 ns (1 allocation: 16 bytes)
  with resizable free list allocator       48.426 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 33.871 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             36.794 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       77.871 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   79.418 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.List                      3.175 μs (23 allocations: 1.29 KiB)
  List without allocator                   144.989 ns (11 allocations: 1.11 KiB)
  with fixed allocator                     48.635 ns (1 allocation: 16 bytes)
  with resizable allocator                 44.838 ns (1 allocation: 16 bytes)
  with fixed free list allocator           81.971 ns (1 allocation: 16 bytes)
  with resizable free list allocator       86.785 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 39.697 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             43.566 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       90.552 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   92.962 ns (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.List                      4.943 μs (23 allocations: 8.32 KiB)
  List without allocator                   880.000 ns (11 allocations: 8.77 KiB)
  with fixed allocator                     189.862 ns (1 allocation: 16 bytes)
  with resizable allocator                 210.315 ns (1 allocation: 16 bytes)
  with fixed free list allocator           549.733 ns (1 allocation: 16 bytes)
  with resizable free list allocator       478.462 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 171.512 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             174.965 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       340.773 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   378.325 ns (1 allocation: 16 bytes)
```

DataStructures.jl's list seems slightly broken. There is a performance gain
 depending on the payload when compared to the allocatorless implementation.

### Stacks

```
100000 elements
 payload of 1 float(s)
  DataStructures.Stack             546.600 μs (198 allocations: 1.55 MiB)
  Stack with fixed allocator       271.400 μs (1 allocation: 16 bytes)
  Stack with resizable allocator   243.100 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Stack             6.673 ms (296 allocations: 8.44 MiB)
  Stack with fixed allocator       526.900 μs (1 allocation: 16 bytes)
  Stack with resizable allocator   480.800 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Stack             17.434 ms (296 allocations: 77.34 MiB)
  Stack with fixed allocator       5.521 ms (1 allocation: 16 bytes)
  Stack with resizable allocator   5.637 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  DataStructures.Stack             962.903 ns (4 allocations: 16.25 KiB)
  Stack with fixed allocator       40.464 ns (1 allocation: 16 bytes)
  Stack with resizable allocator   42.525 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Stack             2.200 μs (5 allocations: 88.20 KiB)
  Stack with fixed allocator       43.939 ns (1 allocation: 16 bytes)
  Stack with resizable allocator   48.077 ns (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Stack             5.033 μs (5 allocations: 808.20 KiB)
  Stack with fixed allocator       196.865 ns (1 allocation: 16 bytes)
  Stack with resizable allocator   189.636 ns (1 allocation: 16 bytes)
```

Comparison with DataStructures.jl's stack shows a performance gain depending on
size of elements and size of the queue.

### Queues

```
100000 elements       
 payload of 1 float(s)
  DataStructures.Queue             334.700 μs (198 allocations: 1.55 MiB)
  Queue with fixed allocator       284.000 μs (1 allocation: 16 bytes)
  Queue with resizable allocator   272.600 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Queue             5.577 ms (296 allocations: 8.44 MiB)
  Queue with fixed allocator       643.700 μs (1 allocation: 16 bytes)
  Queue with resizable allocator   945.700 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Queue             20.430 ms (296 allocations: 77.34 MiB)
  Queue with fixed allocator       5.617 ms (1 allocation: 16 bytes)
  Queue with resizable allocator   6.301 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  DataStructures.Queue             910.526 ns (4 allocations: 16.25 KiB)
  Queue with fixed allocator       34.945 ns (1 allocation: 16 bytes)
  Queue with resizable allocator   39.091 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Queue             2.400 μs (5 allocations: 88.20 KiB)
  Queue with fixed allocator       38.788 ns (1 allocation: 16 bytes)
  Queue with resizable allocator   43.725 ns (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Queue             4.700 μs (5 allocations: 808.20 KiB)
  Queue with fixed allocator       172.303 ns (1 allocation: 16 bytes)
  Queue with resizable allocator   174.483 ns (1 allocation: 16 bytes)
```

Comparison with DataStructures.jl's queue shows a performance gain depending on
size of elements and size of the queue.

### Trees

```
100000 elements
  DataStructures.AVLTree                   4.375 s (7102520 allocations: 114.48 MiB)
  DataStructures.RBTree                    340.134 ms (200003 allocations: 12.21 MiB)
  AVLTrees.AVLSet                          26.044 ms (200002 allocations: 9.16 MiB)
  Tree without allocator                   104.542 ms (200001 allocations: 9.16 MiB)
  with fixed allocator                     83.782 ms (1 allocation: 16 bytes)
  with resizable allocator                 84.495 ms (1 allocation: 16 bytes)
  with fixed free list allocator           79.200 ms (1 allocation: 16 bytes)
  with resizable free list allocator       79.062 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 90.027 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             94.035 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       89.792 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   88.763 ms (1 allocation: 16 bytes)
1000 elements
  DataStructures.AVLTree                   25.958 ms (28637 allocations: 509.97 KiB)
  DataStructures.RBTree                    3.111 ms (2003 allocations: 125.11 KiB)
  AVLTrees.AVLSet                          196.100 μs (2002 allocations: 93.78 KiB)
  Tree without allocator                   654.500 μs (2001 allocations: 93.77 KiB)
  with fixed allocator                     355.600 μs (1 allocation: 16 bytes)
  with resizable allocator                 358.800 μs (1 allocation: 16 bytes)
  with fixed free list allocator           370.900 μs (1 allocation: 16 bytes)
  with resizable free list allocator       374.400 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 459.200 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             459.300 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       476.800 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   475.900 μs (1 allocation: 16 bytes)
10 elements
  DataStructures.AVLTree                   99.100 μs (102 allocations: 2.23 KiB)
  DataStructures.RBTree                    28.900 μs (23 allocations: 1.36 KiB)
  AVLTrees.AVLSet                          1.940 μs (22 allocations: 992 bytes)
  Tree without allocator                   3.312 μs (21 allocations: 976 bytes)
  with fixed allocator                     1.180 μs (1 allocation: 16 bytes)
  with resizable allocator                 1.180 μs (1 allocation: 16 bytes)
  with fixed free list allocator           1.220 μs (1 allocation: 16 bytes)
  with resizable free list allocator       1.430 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 1.770 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             2.020 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       2.144 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   2.150 μs (1 allocation: 16 bytes)
```

DataStructures.jl's `AVLTree` seems slightly broken. Comparison with
DataStructures.jl's `RBTree` and AVLTrees.jl's `AVLSet` shows some performance
gain under certain circumstances.
