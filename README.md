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
  DataStructures.List                  358.912 ms (3994910 allocations: 91.47 MiB)
  List without allocator               6.708 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                 2.745 ms (0 allocations: 0 bytes)
  with resizable allocator             2.895 ms (0 allocations: 0 bytes)
  with fixed free list allocator       2.961 ms (0 allocations: 0 bytes)
  with resizable free list allocator   3.066 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                  388.963 ms (3994910 allocations: 152.51 MiB)
  List without allocator               37.519 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                 7.954 ms (0 allocations: 0 bytes)
  with resizable allocator             7.719 ms (0 allocations: 0 bytes)
  with fixed free list allocator       9.098 ms (0 allocations: 0 bytes)
  with resizable free list allocator   10.546 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                  904.983 ms (3994910 allocations: 839.16 MiB)
  List without allocator               421.160 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                 73.074 ms (0 allocations: 0 bytes)
  with resizable allocator             73.187 ms (0 allocations: 0 bytes)
  with fixed free list allocator       93.607 ms (0 allocations: 0 bytes)
  with resizable free list allocator   88.986 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.List                  361.171 ms (2200000 allocations: 63.32 MiB)
  List without allocator               5.583 ms (1000000 allocations: 30.52 MiB)
  with fixed allocator                 1.791 ms (0 allocations: 0 bytes)
  with resizable allocator             1.954 ms (0 allocations: 0 bytes)
  with fixed free list allocator       2.871 ms (0 allocations: 0 bytes)
  with resizable free list allocator   2.814 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.List                  353.950 ms (2200000 allocations: 124.36 MiB)
  List without allocator               36.147 ms (1000000 allocations: 106.81 MiB)
  with fixed allocator                 2.635 ms (0 allocations: 0 bytes)
  with resizable allocator             2.670 ms (0 allocations: 0 bytes)
  with fixed free list allocator       5.570 ms (0 allocations: 0 bytes)
  with resizable free list allocator   5.790 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.List                  783.336 ms (2200000 allocations: 811.00 MiB)
  List without allocator               392.570 ms (1000000 allocations: 854.49 MiB)
  with fixed allocator                 17.812 ms (0 allocations: 0 bytes)
  with resizable allocator             14.097 ms (0 allocations: 0 bytes)
  with fixed free list allocator       51.190 ms (0 allocations: 0 bytes)
  with resizable free list allocator   45.716 ms (0 allocations: 0 bytes)
```

DataStructures.jl's list seems slightly broken. There is a performance gain
 depending on the payload when compared to the allocatorless implementation.

### Stacks

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Stack             3.540 ms (1943 allocations: 15.35 MiB)
  Stack with fixed allocator       2.409 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   2.692 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             14.739 ms (2914 allocations: 83.58 MiB)
  Stack with fixed allocator       4.654 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   4.941 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             179.883 ms (2914 allocations: 766.31 MiB)
  Stack with fixed allocator       56.829 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   57.216 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Stack             2.795 ms (3 allocations: 16.23 KiB)
  Stack with fixed allocator       2.899 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   2.964 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Stack             5.404 ms (4 allocations: 88.19 KiB)
  Stack with fixed allocator       3.166 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   3.366 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Stack             43.771 ms (4 allocations: 808.19 KiB)
  Stack with fixed allocator       13.677 ms (0 allocations: 0 bytes)
  Stack with resizable allocator   13.754 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's stack shows a performance gain depending on
size of elements and size of the queue.

### Queues

```
10 runs with 100000 elements
 payload of 1 float(s)
  DataStructures.Queue             3.531 ms (1943 allocations: 15.35 MiB)
  Queue with fixed allocator       2.423 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   2.936 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             16.106 ms (2914 allocations: 83.58 MiB)
  Queue with fixed allocator       5.396 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   10.833 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             228.596 ms (2914 allocations: 766.31 MiB)
  Queue with fixed allocator       56.265 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   71.447 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
 payload of 1 float(s)
  DataStructures.Queue             2.879 ms (3 allocations: 16.23 KiB)
  Queue with fixed allocator       2.035 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   2.680 ms (0 allocations: 0 bytes)
 payload of 10 float(s)
  DataStructures.Queue             5.673 ms (4 allocations: 88.19 KiB)
  Queue with fixed allocator       2.477 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   3.006 ms (0 allocations: 0 bytes)
 payload of 100 float(s)
  DataStructures.Queue             43.979 ms (4 allocations: 808.19 KiB)
  Queue with fixed allocator       13.175 ms (0 allocations: 0 bytes)
  Queue with resizable allocator   14.273 ms (0 allocations: 0 bytes)
```

Comparison with DataStructures.jl's queue shows a performance gain depending on
size of elements and size of the queue.

### Trees

```
10 runs with 100000 elements
  DataStructures.AVLTree               20.003 s (33523161 allocations: 542.04 MiB)
  DataStructures.RBTree                1.207 s (1000002 allocations: 61.04 MiB)
  AVLTrees.AVLSet                      791.866 ms (1000001 allocations: 45.78 MiB)
  Tree without allocator               771.991 ms (1000000 allocations: 45.78 MiB)
  with fixed allocator                 300.315 ms (0 allocations: 0 bytes)
  with resizable allocator             322.744 ms (0 allocations: 0 bytes)
  with fixed free list allocator       348.324 ms (0 allocations: 0 bytes)
  with resizable free list allocator   323.139 ms (0 allocations: 0 bytes)
1000 runs with 1000 elements
  DataStructures.AVLTree               11.782 s (13353001 allocations: 234.27 MiB)
  DataStructures.RBTree                1.016 s (1000002 allocations: 61.04 MiB)
  AVLTrees.AVLSet                      772.216 ms (1000001 allocations: 45.78 MiB)
  Tree without allocator               457.861 ms (1000000 allocations: 45.78 MiB)
  with fixed allocator                 143.786 ms (0 allocations: 0 bytes)
  with resizable allocator             155.450 ms (0 allocations: 0 bytes)
  with fixed free list allocator       149.440 ms (0 allocations: 0 bytes)
  with resizable free list allocator   159.500 ms (0 allocations: 0 bytes)
100000 runs with 10 elements
  DataStructures.AVLTree               4.047 s (5000001 allocations: 106.81 MiB)
  DataStructures.RBTree                1.580 s (1000002 allocations: 61.04 MiB)
  AVLTrees.AVLSet                      821.254 ms (1000001 allocations: 45.78 MiB)
  Tree without allocator               203.864 ms (1000000 allocations: 45.78 MiB)
  with fixed allocator                 42.363 ms (0 allocations: 0 bytes)
  with resizable allocator             42.077 ms (0 allocations: 0 bytes)
  with fixed free list allocator       43.949 ms (0 allocations: 0 bytes)
  with resizable free list allocator   44.167 ms (0 allocations: 0 bytes)
```

DataStructures.jl's `AVLTree` seems slightly broken. Comparison with
DataStructures.jl's `RBTree` and AVLTrees.jl's `AVLSet` shows some performance
gain.
