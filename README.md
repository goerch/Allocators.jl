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
- Tree, see example/tree.jl

## Results

Tested on Julia 1.6.3

### Lists

```
100000 elements
 payload of 1 float(s)
  DataStructures.List                      30.480 ms (399492 allocations: 9.15 MiB)
  List without allocator                   661.900 μs (100001 allocations: 3.05 MiB)
  with fixed allocator                     277.300 μs (1 allocation: 16 bytes)
  with resizable allocator                 278.800 μs (1 allocation: 16 bytes)
  with fixed free list allocator           294.400 μs (1 allocation: 16 bytes)
  with resizable free list allocator       314.800 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 262.900 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             284.300 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       611.600 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   633.900 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.List                      31.253 ms (399492 allocations: 15.25 MiB)
  List without allocator                   1.998 ms (100001 allocations: 10.68 MiB)
  with fixed allocator                     641.100 μs (1 allocation: 16 bytes)
  with resizable allocator                 684.200 μs (1 allocation: 16 bytes)
  with fixed free list allocator           898.500 μs (1 allocation: 16 bytes)
  with resizable free list allocator       892.600 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 520.800 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             495.200 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       929.600 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   959.100 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.List                      65.852 ms (399492 allocations: 83.92 MiB)
  List without allocator                   25.055 ms (100001 allocations: 85.45 MiB)
  with fixed allocator                     7.167 ms (1 allocation: 16 bytes)
  with resizable allocator                 6.827 ms (1 allocation: 16 bytes)
  with fixed free list allocator           8.404 ms (1 allocation: 16 bytes)
  with resizable free list allocator       8.356 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 5.329 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             5.311 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       6.579 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   6.537 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  DataStructures.List                      3.550 μs (23 allocations: 680 bytes)
  List without allocator                   70.389 ns (11 allocations: 336 bytes)
  with fixed allocator                     37.966 ns (1 allocation: 16 bytes)
  with resizable allocator                 38.570 ns (1 allocation: 16 bytes)
  with fixed free list allocator           47.778 ns (1 allocation: 16 bytes)
  with resizable free list allocator       44.174 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 33.669 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             36.895 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       76.698 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   79.206 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.List                      3.163 μs (23 allocations: 1.29 KiB)
  List without allocator                   145.949 ns (11 allocations: 1.11 KiB)
  with fixed allocator                     43.636 ns (1 allocation: 16 bytes)
  with resizable allocator                 49.232 ns (1 allocation: 16 bytes)
  with fixed free list allocator           77.847 ns (1 allocation: 16 bytes)
  with resizable free list allocator       78.788 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 45.051 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             48.785 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       88.498 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   90.628 ns (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.List                      4.857 μs (23 allocations: 8.32 KiB)
  List without allocator                   908.696 ns (11 allocations: 8.77 KiB)
  with fixed allocator                     168.396 ns (1 allocation: 16 bytes)
  with resizable allocator                 173.839 ns (1 allocation: 16 bytes)
  with fixed free list allocator           600.000 ns (1 allocation: 16 bytes)
  with resizable free list allocator       552.688 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 191.006 ns (1 allocation: 16 bytes)
  with resizable SOA allocator             200.420 ns (1 allocation: 16 bytes)
  with fixed free list SOA allocator       380.296 ns (1 allocation: 16 bytes)
  with resizable free list SOA allocator   385.000 ns (1 allocation: 16 bytes)
```

DataStructures.jl's list seems slightly broken. There is a performance gain
 depending on the payload when compared to the allocatorless implementation.

### Stacks

```
100000 elements
 payload of 1 float(s)
  DataStructures.Stack             371.200 μs (198 allocations: 1.55 MiB)
  Stack with fixed allocator       222.600 μs (1 allocation: 16 bytes)
  Stack with resizable allocator   223.600 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Stack             5.355 ms (296 allocations: 8.44 MiB)
  Stack with fixed allocator       436.100 μs (1 allocation: 16 bytes)
  Stack with resizable allocator   497.800 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Stack             15.143 ms (296 allocations: 77.34 MiB)
  Stack with fixed allocator       5.341 ms (1 allocation: 16 bytes)
  Stack with resizable allocator   5.409 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  DataStructures.Stack             763.014 ns (4 allocations: 16.25 KiB)
  Stack with fixed allocator       32.628 ns (1 allocation: 16 bytes)
  Stack with resizable allocator   34.677 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Stack             2.300 μs (5 allocations: 88.20 KiB)
  Stack with fixed allocator       37.336 ns (1 allocation: 16 bytes)
  Stack with resizable allocator   48.887 ns (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Stack             4.633 μs (5 allocations: 808.20 KiB)
  Stack with fixed allocator       160.606 ns (1 allocation: 16 bytes)
  Stack with resizable allocator   197.765 ns (1 allocation: 16 bytes)
```

Comparison with DataStructures.jl's stack shows a performance gain depending on
size of elements and size of the queue.

### Queues

```
100000 elements       
 payload of 1 float(s)
  DataStructures.Queue             426.900 μs (198 allocations: 1.55 MiB)
  Queue with fixed allocator       223.700 μs (1 allocation: 16 bytes)
  Queue with resizable allocator   243.900 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Queue             5.602 ms (296 allocations: 8.44 MiB)
  Queue with fixed allocator       518.600 μs (1 allocation: 16 bytes)
  Queue with resizable allocator   887.500 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Queue             13.873 ms (296 allocations: 77.34 MiB)
  Queue with fixed allocator       5.440 ms (1 allocation: 16 bytes)
  Queue with resizable allocator   6.003 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  DataStructures.Queue             783.292 ns (4 allocations: 16.25 KiB)
  Queue with fixed allocator       31.357 ns (1 allocation: 16 bytes)
  Queue with resizable allocator   34.980 ns (1 allocation: 16 bytes)
 payload of 10 float(s)
  DataStructures.Queue             2.400 μs (5 allocations: 88.20 KiB)
  Queue with fixed allocator       36.125 ns (1 allocation: 16 bytes)
  Queue with resizable allocator   41.052 ns (1 allocation: 16 bytes)
 payload of 100 float(s)
  DataStructures.Queue             4.750 μs (5 allocations: 808.20 KiB)
  Queue with fixed allocator       174.127 ns (1 allocation: 16 bytes)
  Queue with resizable allocator   168.168 ns (1 allocation: 16 bytes)
```

Comparison with DataStructures.jl's queue shows a performance gain depending on
size of elements and size of the queue.

### Sets

```
100000 elements
  Set                                      13.051 ms (38 allocations: 7.50 MiB)
  DataStructures.SortedSet                 88.454 ms (91 allocations: 24.57 MiB)
  DataStructures.AVLTree                   3.944 s (7102520 allocations: 114.48 MiB)
  DataStructures.RBTree                    326.611 ms (200003 allocations: 12.21 MiB)
  AVLTrees.AVLSet                          24.457 ms (200002 allocations: 9.16 MiB)
  Tree without allocator                   28.859 ms (200003 allocations: 9.16 MiB)
  with fixed allocator                     47.015 ms (1 allocation: 16 bytes)
  with resizable allocator                 47.303 ms (1 allocation: 16 bytes)
  with fixed free list allocator           40.740 ms (1 allocation: 16 bytes)
  with resizable free list allocator       40.482 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 69.469 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             71.495 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       62.999 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   64.421 ms (1 allocation: 16 bytes)
1000 elements
  Set                                      98.300 μs (18 allocations: 49.58 KiB)
  DataStructures.SortedSet                 347.100 μs (56 allocations: 322.94 KiB)
  DataStructures.AVLTree                   23.874 ms (28637 allocations: 509.97 KiB)
  DataStructures.RBTree                    2.902 ms (2003 allocations: 125.11 KiB)
  AVLTrees.AVLSet                          180.400 μs (2002 allocations: 93.78 KiB)
  Tree without allocator                   222.700 μs (2003 allocations: 93.80 KiB)
  with fixed allocator                     234.900 μs (1 allocation: 16 bytes)
  with resizable allocator                 235.300 μs (1 allocation: 16 bytes)
  with fixed free list allocator           239.800 μs (1 allocation: 16 bytes)
  with resizable free list allocator       239.800 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 384.900 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             390.300 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       392.900 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   396.100 μs (1 allocation: 16 bytes)
10 elements
  Set                                      597.191 ns (8 allocations: 1.33 KiB)
  DataStructures.SortedSet                 2.178 μs (28 allocations: 5.75 KiB)
  DataStructures.AVLTree                   92.200 μs (102 allocations: 2.23 KiB)
  DataStructures.RBTree                    27.200 μs (23 allocations: 1.36 KiB)
  AVLTrees.AVLSet                          1.530 μs (22 allocations: 992 bytes)
  Tree without allocator                   1.240 μs (21 allocations: 976 bytes)
  with fixed allocator                     738.889 ns (1 allocation: 16 bytes)
  with resizable allocator                 724.812 ns (1 allocation: 16 bytes)
  with fixed free list allocator           752.174 ns (1 allocation: 16 bytes)
  with resizable free list allocator       770.192 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 1.760 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             1.770 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       1.880 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   1.870 μs (1 allocation: 16 bytes)
```

DataStructures.jl's `AVLTree` seems slightly broken. Comparison with
DataStructures.jl's `RBTree` shows some performance gain.

### Dicts

```
100000 elements
 payload of 1 float(s)
  Dict                                     16.023 ms (43 allocations: 14.17 MiB)
  DataStructures.SortedDict                88.906 ms (89 allocations: 27.07 MiB)
  Tree without allocator                   35.453 ms (200003 allocations: 12.21 MiB)
  with fixed allocator                     61.903 ms (1 allocation: 16 bytes)
  with resizable allocator                 62.143 ms (1 allocation: 16 bytes)
  with fixed free list allocator           51.303 ms (1 allocation: 16 bytes)
  with resizable free list allocator       49.445 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 74.348 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             69.639 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       69.527 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   70.950 ms (1 allocation: 16 bytes)
 payload of 10 float(s)
  Dict                                     44.331 ms (45 allocations: 74.17 MiB)
  DataStructures.SortedDict                101.390 ms (89 allocations: 45.07 MiB)
  Tree without allocator                   42.806 ms (200003 allocations: 24.41 MiB)
  with fixed allocator                     56.049 ms (1 allocation: 16 bytes)
  with resizable allocator                 60.099 ms (1 allocation: 16 bytes)
  with fixed free list allocator           52.181 ms (1 allocation: 16 bytes)
  with resizable free list allocator       51.759 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 86.210 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             83.910 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       77.192 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   79.074 ms (1 allocation: 16 bytes)
 payload of 100 float(s)
  Dict                                     273.226 ms (46 allocations: 674.17 MiB)
  DataStructures.SortedDict                207.487 ms (89 allocations: 225.16 MiB)
  Tree without allocator                   274.195 ms (200003 allocations: 170.90 MiB)
  with fixed allocator                     112.010 ms (1 allocation: 16 bytes)
  with resizable allocator                 113.171 ms (1 allocation: 16 bytes)
  with fixed free list allocator           118.668 ms (1 allocation: 16 bytes)
  with resizable free list allocator       114.131 ms (1 allocation: 16 bytes)
  with fixed SOA allocator                 156.257 ms (1 allocation: 16 bytes)
  with resizable SOA allocator             157.835 ms (1 allocation: 16 bytes)
  with fixed free list SOA allocator       164.348 ms (1 allocation: 16 bytes)
  with resizable free list SOA allocator   163.778 ms (1 allocation: 16 bytes)
10 elements
 payload of 1 float(s)
  Dict                                     657.851 ns (8 allocations: 1.98 KiB)
  DataStructures.SortedDict                2.211 μs (26 allocations: 6.16 KiB)
  Tree without allocator                   1.180 μs (21 allocations: 1.27 KiB)
  with fixed allocator                     788.421 ns (1 allocation: 16 bytes)
  with resizable allocator                 784.158 ns (1 allocation: 16 bytes)
  with fixed free list allocator           822.222 ns (1 allocation: 16 bytes)
  with resizable free list allocator       827.273 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 2.220 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             2.220 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       2.089 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   2.111 μs (1 allocation: 16 bytes)
 payload of 10 float(s)
  Dict                                     881.818 ns (8 allocations: 7.62 KiB)
  DataStructures.SortedDict                2.400 μs (26 allocations: 10.64 KiB)
  Tree without allocator                   2.100 μs (21 allocations: 2.52 KiB)
  with fixed allocator                     925.714 ns (1 allocation: 16 bytes)
  with resizable allocator                 929.032 ns (1 allocation: 16 bytes)
  with fixed free list allocator           1.127 μs (1 allocation: 16 bytes)
  with resizable free list allocator       980.000 ns (1 allocation: 16 bytes)
  with fixed SOA allocator                 2.744 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             2.367 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       2.500 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   2.811 μs (1 allocation: 16 bytes)
 payload of 100 float(s)
  Dict                                     3.414 μs (9 allocations: 63.88 KiB)
  DataStructures.SortedDict                6.080 μs (26 allocations: 54.36 KiB)
  Tree without allocator                   12.200 μs (21 allocations: 17.52 KiB)
  with fixed allocator                     3.125 μs (1 allocation: 16 bytes)
  with resizable allocator                 3.138 μs (1 allocation: 16 bytes)
  with fixed free list allocator           3.737 μs (1 allocation: 16 bytes)
  with resizable free list allocator       3.250 μs (1 allocation: 16 bytes)
  with fixed SOA allocator                 5.867 μs (1 allocation: 16 bytes)
  with resizable SOA allocator             5.900 μs (1 allocation: 16 bytes)
  with fixed free list SOA allocator       5.867 μs (1 allocation: 16 bytes)
  with resizable free list SOA allocator   5.850 μs (1 allocation: 16 bytes)
```
