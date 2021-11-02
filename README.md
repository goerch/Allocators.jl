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
- Set, see example/set.jl
- Dict see example/dict.jl

## Results

Tested on Julia 1.6.3

### Lists

```
100000 elements
 payload of 1 float(s)
  DataStructures.List                      29.633 ms (399492 allocations: 9.15 MiB)
  List without allocator                   599.500 μs (100001 allocations: 3.05 MiB)
  with fixed allocator                     288.900 μs (1 allocation: 16 bytes)
  with resizable allocator                 285.700 μs (1 allocation: 16 bytes)
  with fixed free list allocator           306.100 μs (1 allocation: 16 bytes)
  with resizable free list allocator       304.700 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 262.900 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             282.900 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       335.700 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   357.800 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.List                      30.070 ms (399492 allocations: 15.25 MiB)
  List without allocator                   2.134 ms (100001 allocations: 10.68 MiB)
  with fixed allocator                     745.000 μs (1 allocation: 16 bytes)
  with resizable allocator                 684.900 μs (1 allocation: 16 bytes)
  with fixed free list allocator           925.400 μs (1 allocation: 16 bytes)
  with resizable free list allocator       880.100 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 494.900 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             481.200 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       957.800 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   960.400 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.List                      65.440 ms (399492 allocations: 83.92 MiB)
  List without allocator                   24.405 ms (100001 allocations: 85.45 MiB)
  with fixed allocator                     7.327 ms (1 allocation: 16 bytes)
  with resizable allocator                 7.195 ms (1 allocation: 16 bytes)
  with fixed free list allocator           8.601 ms (1 allocation: 16 bytes)
  with resizable free list allocator       8.580 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 5.466 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             5.437 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       7.389 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   7.522 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  DataStructures.List                      3.013 μs (23 allocations: 680 bytes)
  List without allocator                   68.712 ns (11 allocations: 336 bytes)
  with fixed allocator                     33.837 ns (1 allocation: 16 bytes)
  with resizable allocator                 33.065 ns (1 allocation: 16 bytes)
  with fixed free list allocator           47.475 ns (1 allocation: 16 bytes)
  with resizable free list allocator       44.231 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 33.837 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             36.959 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       50.152 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   51.833 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.List                      3.163 μs (23 allocations: 1.29 KiB)
  List without allocator                   147.619 ns (11 allocations: 1.11 KiB)
  with fixed allocator                     40.546 ns (1 allocation: 16 bytes)
  with resizable allocator                 46.970 ns (1 allocation: 16 bytes)
  with fixed free list allocator           79.062 ns (1 allocation: 16 bytes)
  with resizable free list allocator       82.952 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 40.344 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             40.950 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       82.073 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   96.947 ns (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.List                      5.171 μs (23 allocations: 8.32 KiB)
  List without allocator                   912.903 ns (11 allocations: 8.77 KiB)
  with fixed allocator                     181.081 ns (1 allocation: 16 bytes)
  with resizable allocator                 194.118 ns (1 allocation: 16 bytes)
  with fixed free list allocator           477.222 ns (1 allocation: 16 bytes)
  with resizable free list allocator       478.462 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 174.468 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             176.623 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       505.641 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   477.949 ns (1 allocation: 16 bytes)
```

DataStructures.jl's list seems slightly broken. There is a performance gain
 depending on the payload when compared to the allocatorless implementation.

### Stacks

```
100000 elements
 payload of 1 float(s)
  DataStructures.Stack             518.300 μs (198 allocations: 1.55 MiB)
  Stack with fixed allocator       221.700 μs (1 allocation: 16 bytes)
  Stack with resizable allocator   223.600 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Stack             5.120 ms (296 allocations: 8.44 MiB)
  Stack with fixed allocator       462.000 μs (1 allocation: 16 bytes)
  Stack with resizable allocator   460.000 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Stack             19.755 ms (296 allocations: 77.34 MiB)
  Stack with fixed allocator       5.377 ms (1 allocation: 16 bytes)
  Stack with resizable allocator   5.473 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  DataStructures.Stack             842.857 ns (4 allocations: 16.25 KiB)
  Stack with fixed allocator       32.326 ns (1 allocation: 16 bytes)
  Stack with resizable allocator   34.778 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Stack             2.400 μs (5 allocations: 88.20 KiB)
  Stack with fixed allocator       38.345 ns (1 allocation: 16 bytes)
  Stack with resizable allocator   46.512 ns (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Stack             4.200 μs (5 allocations: 808.20 KiB)
  Stack with fixed allocator       170.380 ns (1 allocation: 16 bytes)
  Stack with resizable allocator   158.540 ns (1 allocation: 16 bytes)
```

Comparison with DataStructures.jl's stack shows a performance gain depending on
size of elements and size of the stack.

### Queues

```
100000 elements
 payload of 1 float(s)
  DataStructures.Queue             452.100 μs (198 allocations: 1.55 MiB)
  Queue with fixed allocator       223.300 μs (1 allocation: 16 bytes)
  Queue with resizable allocator   243.700 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Queue             5.008 ms (296 allocations: 8.44 MiB)
  Queue with fixed allocator       477.500 μs (1 allocation: 16 bytes)
  Queue with resizable allocator   918.700 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Queue             18.375 ms (296 allocations: 77.34 MiB)
  Queue with fixed allocator       5.433 ms (1 allocation: 16 bytes)
  Queue with resizable allocator   6.161 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  DataStructures.Queue             788.571 ns (4 allocations: 16.25 KiB)
  Queue with fixed allocator       31.319 ns (1 allocation: 16 bytes)
  Queue with resizable allocator   34.980 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Queue             2.400 μs (5 allocations: 88.20 KiB)
  Queue with fixed allocator       35.520 ns (1 allocation: 16 bytes)
  Queue with resizable allocator   38.648 ns (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Queue             4.200 μs (5 allocations: 808.20 KiB)
  Queue with fixed allocator       155.907 ns (1 allocation: 16 bytes)
  Queue with resizable allocator   187.885 ns (1 allocation: 16 bytes)
```

Comparison with DataStructures.jl's queue shows a performance gain depending on
size of elements and size of the queue.

### Sets

```
100000 elements
  Set                                      14.487 ms (38 allocations: 7.50 MiB)
  DataStructures.SortedSet                 100.822 ms (91 allocations: 24.57 MiB)
  DataStructures.AVLTree                   4.112 s (7102520 allocations: 114.48 MiB)
  DataStructures.RBTree                    306.725 ms (200003 allocations: 12.21 MiB)
  DataStructures.SplayTree                 210.642 ms (200002 allocations: 9.16 MiB)
  AVLTrees.AVLSet                          24.511 ms (200002 allocations: 9.16 MiB)
  Tree without allocator                   30.209 ms (200003 allocations: 9.16 MiB)
  with fixed allocator                     50.160 ms (1 allocation: 16 bytes)
  with resizable allocator                 46.871 ms (1 allocation: 16 bytes)
  with fixed free list allocator           39.556 ms (1 allocation: 16 bytes)
  with resizable free list allocator       38.750 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 48.219 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             50.328 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       46.498 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   45.623 ms (1 allocation: 16 bytes)
1000 elements
  Set                                      114.100 μs (18 allocations: 49.58 KiB)
  DataStructures.SortedSet                 344.400 μs (56 allocations: 322.94 KiB)
  DataStructures.AVLTree                   23.755 ms (28637 allocations: 509.97 KiB)
  DataStructures.RBTree                    3.016 ms (2003 allocations: 125.11 KiB)
  DataStructures.SplayTree                 1.934 ms (2002 allocations: 93.80 KiB)
  AVLTrees.AVLSet                          178.300 μs (2002 allocations: 93.78 KiB)
  Tree without allocator                   229.500 μs (2003 allocations: 93.80 KiB)
  with fixed allocator                     233.700 μs (1 allocation: 16 bytes)
  with resizable allocator                 235.100 μs (1 allocation: 16 bytes)
  with fixed free list allocator           237.000 μs (1 allocation: 16 bytes)
  with resizable free list allocator       236.700 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 207.000 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             206.900 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       239.400 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   226.200 μs (1 allocation: 16 bytes)
10 elements
  Set                                      600.000 ns (8 allocations: 1.33 KiB)
  DataStructures.SortedSet                 2.156 μs (28 allocations: 5.75 KiB)
  DataStructures.AVLTree                   92.900 μs (102 allocations: 2.23 KiB)
  DataStructures.RBTree                    29.000 μs (23 allocations: 1.36 KiB)
  DataStructures.SplayTree                 17.600 μs (22 allocations: 1008 bytes)
  AVLTrees.AVLSet                          1.680 μs (22 allocations: 992 bytes)
  Tree without allocator                   1.090 μs (21 allocations: 976 bytes)
  with fixed allocator                     740.496 ns (1 allocation: 16 bytes)
  with resizable allocator                 739.344 ns (1 allocation: 16 bytes)
  with fixed free list allocator           775.701 ns (1 allocation: 16 bytes)
  with resizable free list allocator       783.146 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 900.000 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             900.000 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       983.333 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   990.909 ns (1 allocation: 16 bytes)
```

DataStructures.jl's `AVLTree` seems slightly broken. Comparison with
DataStructures.jl's `RBTree` shows some performance gain.

### Dicts

```
100000 elements
 payload of 1 float(s)
  Dict                                     16.163 ms (43 allocations: 14.17 MiB)
  DataStructures.SortedDict                90.442 ms (89 allocations: 27.07 MiB)
  Tree without allocator                   31.310 ms (200003 allocations: 12.21 MiB)
  with fixed allocator                     62.263 ms (1 allocation: 16 bytes)
  with resizable allocator                 57.194 ms (1 allocation: 16 bytes)
  with fixed free list allocator           52.989 ms (1 allocation: 16 bytes)
  with resizable free list allocator       53.139 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 59.074 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             49.803 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       52.881 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   48.492 ms (1 allocation: 16 bytes)
 payload of 10 float(s)
  Dict                                     42.391 ms (45 allocations: 74.17 MiB)
  DataStructures.SortedDict                96.470 ms (89 allocations: 45.07 MiB)
  Tree without allocator                   36.104 ms (200003 allocations: 24.41 MiB)
  with fixed allocator                     58.300 ms (1 allocation: 16 bytes)
  with resizable allocator                 63.216 ms (1 allocation: 16 bytes)
  with fixed free list allocator           52.756 ms (1 allocation: 16 bytes)
  with resizable free list allocator       53.264 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 55.434 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             53.171 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       53.637 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   52.726 ms (1 allocation: 16 bytes)
 payload of 100 float(s)
  Dict                                     268.834 ms (46 allocations: 674.17 MiB)
  DataStructures.SortedDict                182.329 ms (89 allocations: 225.16 MiB)
  Tree without allocator                   117.662 ms (200003 allocations: 170.90 MiB)
  with fixed allocator                     127.329 ms (1 allocation: 16 bytes)
  with resizable allocator                 127.174 ms (1 allocation: 16 bytes)
  with fixed free list allocator           125.376 ms (1 allocation: 16 bytes)
  with resizable free list allocator       124.264 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 101.872 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             102.102 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       123.621 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   112.293 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  Dict                                     774.468 ns (8 allocations: 1.98 KiB)
  DataStructures.SortedDict                2.778 μs (26 allocations: 6.16 KiB)
  Tree without allocator                   1.370 μs (21 allocations: 1.27 KiB)
  with fixed allocator                     802.222 ns (1 allocation: 16 bytes)
  with resizable allocator                 783.333 ns (1 allocation: 16 bytes)
  with fixed free list allocator           828.169 ns (1 allocation: 16 bytes)
  with resizable free list allocator       970.833 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 858.621 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             862.712 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       963.636 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   984.615 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  Dict                                     1.320 μs (8 allocations: 7.62 KiB)
  DataStructures.SortedDict                3.311 μs (26 allocations: 10.64 KiB)
  Tree without allocator                   1.420 μs (21 allocations: 2.52 KiB)
  with fixed allocator                     980.000 ns (1 allocation: 16 bytes)
  with resizable allocator                 934.483 ns (1 allocation: 16 bytes)
  with fixed free list allocator           1.010 μs (1 allocation: 16 bytes)
  with resizable free list allocator       1.010 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 1.000 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             1.170 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       1.230 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   1.090 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  Dict                                     4.783 μs (9 allocations: 63.88 KiB)
  DataStructures.SortedDict                7.025 μs (26 allocations: 54.36 KiB)
  Tree without allocator                   2.833 μs (21 allocations: 17.52 KiB)
  with fixed allocator                     3.413 μs (1 allocation: 16 bytes)
  with resizable allocator                 3.425 μs (1 allocation: 16 bytes)
  with fixed free list allocator           3.550 μs (1 allocation: 16 bytes)
  with resizable free list allocator       3.625 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 2.711 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             3.078 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       2.689 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   2.689 μs (1 allocation: 16 bytes)
```
