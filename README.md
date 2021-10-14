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
  DataStructures.List                  340.921 ms (3994910 allocations: 91.47 MiB)
  List without allocator               6.668 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                 2.772 ms (0 allocations: 0 bytes)
  with resizable allocator             2.765 ms (0 allocations: 0 bytes)
  with fixed free list allocator       2.956 ms (0 allocations: 0 bytes)
  with resizable free list allocator   3.079 ms (0 allocations: 0 bytes)
  with fixed SOA allocator             2.432 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                  363.600 ms (3994910 allocations: 152.51 MiB)
  List without allocator               31.530 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                 7.092 ms (0 allocations: 0 bytes)
  with resizable allocator             6.479 ms (0 allocations: 0 bytes)
  with fixed free list allocator       10.442 ms (0 allocations: 0 bytes)
  with resizable free list allocator   10.238 ms (0 allocations: 0 bytes)
  with fixed SOA allocator             4.737 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                  775.576 ms (3994910 allocations: 839.16 MiB)
  List without allocator               349.005 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                 75.338 ms (0 allocations: 0 bytes)
  with resizable allocator             74.300 ms (0 allocations: 0 bytes)
  with fixed free list allocator       86.775 ms (0 allocations: 0 bytes)
  with resizable free list allocator   85.706 ms (0 allocations: 0 bytes)
  with fixed SOA allocator             54.932 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.List                  339.834 ms (2200000 allocations: 63.32 MiB)
  List without allocator               5.002 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                 1.788 ms (0 allocations: 0 bytes)
  with resizable allocator             1.955 ms (0 allocations: 0 bytes)
  with fixed free list allocator       2.739 ms (0 allocations: 0 bytes)
  with resizable free list allocator   2.807 ms (0 allocations: 0 bytes)
  with fixed SOA allocator             1.856 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                  358.853 ms (2200000 allocations: 124.36 MiB)
  List without allocator               28.896 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                 2.575 ms (0 allocations: 0 bytes)
  with resizable allocator             2.715 ms (0 allocations: 0 bytes)
  with fixed free list allocator       5.736 ms (0 allocations: 0 bytes)
  with resizable free list allocator   5.630 ms (0 allocations: 0 bytes)
  with fixed SOA allocator             2.403 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                  741.641 ms (2200000 allocations: 811.00 MiB)
  List without allocator               344.452 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                 14.829 ms (0 allocations: 0 bytes)
  with resizable allocator             13.826 ms (0 allocations: 0 bytes)
  with fixed free list allocator       45.202 ms (0 allocations: 0 bytes)
  with resizable free list allocator   47.779 ms (0 allocations: 0 bytes)
  with fixed SOA allocator             12.584 ms (0 allocations: 0 bytes)
```

DataStructures.jl's list seems slightly broken. There is a performance gain
 depending on the payload when compared to the allocatorless implementation.

### Stacks

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Stack             3.715 ms (1943 allocations: 15.35 MiB)
  Stack with fixed allocator       2.389 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   2.570 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             27.801 ms (2914 allocations: 83.58 MiB)
  Stack with fixed allocator       4.971 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   5.013 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             247.311 ms (2914 allocations: 766.31 MiB)
  Stack with fixed allocator       55.665 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   57.588 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Stack             2.612 ms (3 allocations: 16.23 KiB)
  Stack with fixed allocator       2.464 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   2.740 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             5.397 ms (4 allocations: 88.19 KiB)
  Stack with fixed allocator       2.822 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   3.564 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             44.654 ms (4 allocations: 808.19 KiB)
  Stack with fixed allocator       15.950 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   14.410 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's stack shows a performance gain depending on
size of elements and size of the queue.

### Queues

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Queue             3.513 ms (1943 allocations: 15.35 MiB)
  Queue with fixed allocator       2.410 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   2.948 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             20.617 ms (2914 allocations: 83.58 MiB)
  Queue with fixed allocator       5.602 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   10.844 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             248.649 ms (2914 allocations: 766.31 MiB)
  Queue with fixed allocator       56.421 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   71.189 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Queue             2.611 ms (3 allocations: 16.23 KiB)
  Queue with fixed allocator       2.041 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   2.824 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             5.712 ms (4 allocations: 88.19 KiB)
  Queue with fixed allocator       2.473 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   3.278 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             43.829 ms (4 allocations: 808.19 KiB)
  Queue with fixed allocator       13.399 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   15.077 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's queue shows a performance gain depending on
size of elements and size of the queue.

### Trees

```
10 runs with 100000 elements
  DataStructures.AVLTree               19.597 s (33523161 allocations: 542.04 MiB)
  DataStructures.RBTree                1.227 s (1000002 allocations: 61.04 MiB)
  AVLTrees.AVLSet                      567.133 ms (1000001 allocations: 45.78 MiB)
  Tree without allocator               755.193 ms (1000000 allocations: 45.78 MiB)
  with fixed allocator                 309.765 ms (0 allocations: 0 bytes)
  with resizable allocator             303.401 ms (0 allocations: 0 bytes)
  with fixed free list allocator       312.776 ms (0 allocations: 0 bytes)
  with resizable free list allocator   322.476 ms (0 allocations: 0 bytes)
  with fixed SOA allocator             242.196 ms (0 allocations: 0 bytes)
1000 runs with 1000 elements
  DataStructures.AVLTree               12.370 s (13353001 allocations: 234.27 MiB)
  DataStructures.RBTree                1.002 s (1000002 allocations: 61.04 MiB)
  AVLTrees.AVLSet                      544.806 ms (1000001 allocations: 45.78 MiB)
  Tree without allocator               480.989 ms (1000000 allocations: 45.78 MiB)
  with fixed allocator                 139.582 ms (0 allocations: 0 bytes)
  with resizable allocator             137.872 ms (0 allocations: 0 bytes)
  with fixed free list allocator       146.547 ms (0 allocations: 0 bytes)
  with resizable free list allocator   145.721 ms (0 allocations: 0 bytes)
  with fixed SOA allocator             150.325 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
  DataStructures.AVLTree               3.904 s (5000001 allocations: 106.81 MiB)
  DataStructures.RBTree                1.527 s (1000002 allocations: 61.04 MiB)
  AVLTrees.AVLSet                      749.881 ms (1000001 allocations: 45.78 MiB)
  Tree without allocator               191.684 ms (1000000 allocations: 45.78 MiB)
  with fixed allocator                 41.411 ms (0 allocations: 0 bytes)
  with resizable allocator             41.782 ms (0 allocations: 0 bytes)
  with fixed free list allocator       43.218 ms (0 allocations: 0 bytes)
  with resizable free list allocator   44.192 ms (0 allocations: 0 bytes)
  with fixed SOA allocator             45.648 ms (0 allocations: 0 bytes)
  ```

DataStructures.jl's `AVLTree` seems slightly broken. Comparison with
DataStructures.jl's `RBTree` and AVLTrees.jl's `AVLSet` shows some performance
gain.
