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
  DataStructures.List                      372.640 ms (3994910 allocations: 91.47 MiB)
  List without allocator                   7.118 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                     3.147 ms (0 allocations: 0 bytes)
  with resizable allocator                 3.178 ms (0 allocations: 0 bytes)
  with fixed free list allocator           3.378 ms (0 allocations: 0 bytes)
  with resizable free list allocator       3.498 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 2.526 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             3.075 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       6.209 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   6.558 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                      356.769 ms (3994910 allocations: 152.51 MiB)
  List without allocator                   28.377 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                     7.542 ms (0 allocations: 0 bytes)
  with resizable allocator                 7.883 ms (0 allocations: 0 bytes)
  with fixed free list allocator           10.425 ms (0 allocations: 0 bytes)
  with resizable free list allocator       10.530 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 5.676 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             5.500 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       11.347 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   11.227 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                      792.773 ms (3994910 allocations: 839.16 MiB)
  List without allocator                   368.565 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                     76.010 ms (0 allocations: 0 bytes)
  with resizable allocator                 74.857 ms (0 allocations: 0 bytes)
  with fixed free list allocator           94.872 ms (0 allocations: 0 bytes)
  with resizable free list allocator       92.705 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 57.848 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             57.209 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       74.574 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   75.285 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.List                      374.652 ms (2200000 allocations: 63.32 MiB)
  List without allocator                   5.581 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                     2.066 ms (0 allocations: 0 bytes)
  with resizable allocator                 1.951 ms (0 allocations: 0 bytes)
  with fixed free list allocator           3.147 ms (0 allocations: 0 bytes)
  with resizable free list allocator       2.806 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 2.290 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             2.596 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       5.969 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   6.207 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                      371.420 ms (2200000 allocations: 124.36 MiB)
  List without allocator                   33.711 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                     2.576 ms (0 allocations: 0 bytes)
  with resizable allocator                 2.716 ms (0 allocations: 0 bytes)
  with fixed free list allocator           5.707 ms (0 allocations: 0 bytes)
  with resizable free list allocator       5.592 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 2.777 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             2.998 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       7.353 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   7.517 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                      783.236 ms (2200000 allocations: 811.00 MiB)
  List without allocator                   359.336 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                     14.283 ms (0 allocations: 0 bytes)
  with resizable allocator                 14.488 ms (0 allocations: 0 bytes)
  with fixed free list allocator           45.049 ms (0 allocations: 0 bytes)
  with resizable free list allocator       46.728 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 15.653 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             17.111 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       30.793 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   31.263 ms (0 allocations: 0 bytes)
```

DataStructures.jl's list seems slightly broken. There is a performance gain
 depending on the payload when compared to the allocatorless implementation.

### Stacks

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Stack             5.932 ms (1943 allocations: 15.35 MiB)
  Stack with fixed allocator       2.393 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   2.581 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             23.504 ms (2914 allocations: 83.58 MiB)
  Stack with fixed allocator       4.615 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   5.318 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             267.515 ms (2914 allocations: 766.31 MiB)
  Stack with fixed allocator       58.029 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   58.009 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Stack             2.958 ms (3 allocations: 16.23 KiB)
  Stack with fixed allocator       2.814 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   3.122 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             6.111 ms (4 allocations: 88.19 KiB)
  Stack with fixed allocator       2.829 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   3.703 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             44.456 ms (4 allocations: 808.19 KiB)
  Stack with fixed allocator       14.321 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   13.998 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's stack shows a performance gain depending on
size of elements and size of the queue.

### Queues

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Queue             3.966 ms (1943 allocations: 15.35 MiB)
  Queue with fixed allocator       2.775 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   3.400 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             57.603 ms (2914 allocations: 83.58 MiB)
  Queue with fixed allocator       6.482 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   11.049 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             290.831 ms (2914 allocations: 766.31 MiB)
  Queue with fixed allocator       58.799 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   72.091 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Queue             2.990 ms (3 allocations: 16.23 KiB)
  Queue with fixed allocator       2.335 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   3.039 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             6.649 ms (4 allocations: 88.19 KiB)
  Queue with fixed allocator       2.517 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   3.727 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             50.269 ms (4 allocations: 808.19 KiB)
  Queue with fixed allocator       15.136 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   15.146 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's queue shows a performance gain depending on
size of elements and size of the queue.

### Trees

```
10 runs with 100000 elements
  DataStructures.AVLTree                   20.570 s (33523161 allocations: 542.04 MiB)
  DataStructures.RBTree                    1.195 s (1000002 allocations: 61.04 MiB)
  AVLTrees.AVLSet                          643.322 ms (1000001 allocations: 45.78 MiB)
  Tree without allocator                   748.818 ms (1000000 allocations: 45.78 MiB)
  with fixed allocator                     284.573 ms (0 allocations: 0 bytes)
  with resizable allocator                 285.406 ms (0 allocations: 0 bytes)
  with fixed free list allocator           304.988 ms (0 allocations: 0 bytes)
  with resizable free list allocator       304.674 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 433.482 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             440.935 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       491.784 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   502.906 ms (0 allocations: 0 bytes)
1000 runs with 1000 elements
  DataStructures.AVLTree                   12.009 s (13353001 allocations: 234.27 MiB)
  DataStructures.RBTree                    1.025 s (1000002 allocations: 61.04 MiB)
  AVLTrees.AVLSet                          556.872 ms (1000001 allocations: 45.78 MiB)
  Tree without allocator                   450.270 ms (1000000 allocations: 45.78 MiB)
  with fixed allocator                     140.453 ms (0 allocations: 0 bytes)
  with resizable allocator                 139.258 ms (0 allocations: 0 bytes)
  with fixed free list allocator           142.702 ms (0 allocations: 0 bytes)
  with resizable free list allocator       142.921 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 233.454 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             243.911 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       314.549 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   315.900 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
  DataStructures.AVLTree                   4.495 s (5000001 allocations: 106.81 MiB)
  DataStructures.RBTree                    1.735 s (1000002 allocations: 61.04 MiB)
  AVLTrees.AVLSet                          915.216 ms (1000001 allocations: 45.78 MiB)
  Tree without allocator                   224.845 ms (1000000 allocations: 45.78 MiB)
  with fixed allocator                     45.195 ms (0 allocations: 0 bytes)
  with resizable allocator                 46.879 ms (0 allocations: 0 bytes)
  with fixed free list allocator           49.589 ms (0 allocations: 0 bytes)
  with resizable free list allocator       50.855 ms (0 allocations: 0 bytes)
  with fixed SOA allocator                 87.538 ms (0 allocations: 0 bytes)
  with resizable SOA allocator             87.777 ms (0 allocations: 0 bytes)
  with fixed free list SOA allocator       101.727 ms (0 allocations: 0 bytes)
  with resizable free list SOA allocator   103.042 ms (0 allocations: 0 bytes)
```

DataStructures.jl's `AVLTree` seems slightly broken. Comparison with
DataStructures.jl's `RBTree` and AVLTrees.jl's `AVLSet` shows some performance
gain.
