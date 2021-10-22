import DataStructures
import AVLTrees
using BenchmarkTools
using Profile

include("../src/soalight.jl")
include("../src/allocator.jl")
include("../src/tree.jl")

function testbase1(n)
    tree = Set{Int}()
    for j in 1:n[]
        push!(tree, j)
        push!(tree, -j)
    end
    @assert !(0 in tree)
    for j in 1:n[]
        @assert j in tree
        @assert -j in tree
    end
    @assert !(n[] + 1 in tree)
    @assert !(-n[] - 1 in tree)
    for j in 1:n[]
        @assert j in tree
        @assert -j in tree
        pop!(tree, j)
        pop!(tree, -j)
        @assert !(j in tree)
        @assert !(-j in tree)
    end
end

function testbase2(n)
    tree = DataStructures.SortedSet{Int}()
    for j in 1:n[]
        push!(tree, j)
        push!(tree, -j)
    end
    @assert !haskey(tree, 0)
    for j in 1:n[]
        @assert haskey(tree, j)
        @assert haskey(tree, -j)
    end
    @assert !haskey(tree, n[] + 1)
    @assert !haskey(tree, -n[] - 1)
    for j in 1:n[]
        @assert haskey(tree, j)
        @assert haskey(tree, -j)
        pop!(tree, j)
        pop!(tree, -j)
        @assert !haskey(tree, j)
        @assert !haskey(tree, -j)
    end
end

function testbase3(n)
    tree = DataStructures.AVLTree{Int}()
    for j in 1:n[]
        insert!(tree, j)
        insert!(tree, -j)
    end
    @assert !haskey(tree, 0)
    for j in 1:n[]
        @assert haskey(tree, j)
        @assert haskey(tree, -j)
    end
    @assert !haskey(tree, n[] + 1)
    @assert !haskey(tree, -n[] - 1)
    for j in 1:n[]
        @assert haskey(tree, j)
        @assert haskey(tree, -j)
        delete!(tree, j)
        delete!(tree, -j)
        @assert !haskey(tree, j)
        @assert !haskey(tree, -j)
    end
end

function testbase4(n)
    tree = DataStructures.RBTree{Int}()
    for j in 1:n[]
        insert!(tree, j)
        insert!(tree, -j)
    end
    @assert !haskey(tree, 0)
    for j in 1:n[]
        @assert haskey(tree, j)
        @assert haskey(tree, -j)
    end
    @assert !haskey(tree, n[] + 1)
    @assert !haskey(tree, -n[] - 1)
    for j in 1:n[]
        @assert haskey(tree, j)
        @assert haskey(tree, -j)
        delete!(tree, j)
        delete!(tree, -j)
        @assert !haskey(tree, j)
        @assert !haskey(tree, -j)
    end
end

function testbase5(n)
    tree = AVLTrees.AVLSet{Int}()
    for j in 1:n[]
        push!(tree, j)
        push!(tree, -j)
    end
    @assert !(0 in tree)
    for j in 1:n[]
        @assert j in tree
        @assert -j in tree
    end
    @assert !(n[] + 1 in tree)
    @assert !(-n[] - 1 in tree)
    for j in 1:n[]
        @assert j in tree
        @assert -j in tree
        delete!(tree, j)
        delete!(tree, -j)
        @assert !(j in tree)
        @assert !(-j in tree)
    end
end

function testbase6(n)
    tree = nil()
    for j in 1:n[]
        tree = insert(tree, j, nothing)
        tree = insert(tree, -j, nothing)
    end
    @assert !haskey(tree, 0)
    for j in 1:n[]
        @assert haskey(tree, j)
        @assert haskey(tree, -j)
    end
    @assert !haskey(tree, n[] + 1)
    @assert !haskey(tree, -n[] - 1)
    for j in 1:n[]
        @assert haskey(tree, j)
        @assert haskey(tree, -j)
        tree = delete(tree, j)
        tree = delete(tree, -j)
        @assert !haskey(tree, j)
        @assert !haskey(tree, -j)
    end
end

function testalloc(n, alloc)
    tree = nil(alloc)
    for j in 1:n[]
        tree = insert(tree, j, nothing, alloc)
        tree = insert(tree, -j, nothing, alloc)
    end
    @assert !haskey(tree, 0, alloc)
    for j in 1:n[]
        @assert haskey(tree, j, alloc)
        @assert haskey(tree, -j, alloc)
    end
    @assert !haskey(tree, n[] + 1, alloc)
    @assert !haskey(tree, -n[] - 1, alloc)
    for j in 1:n[]
        @assert haskey(tree, j, alloc)
        @assert haskey(tree, -j, alloc)
        tree = delete(tree, j, alloc)
        tree = delete(tree, -j, alloc)
        @assert !haskey(tree, j, alloc)
        @assert !haskey(tree, -j, alloc)
    end
    emptyend!(alloc)
end

function testfree(n, alloc)
    tree = nil(alloc)
    for j in 1:n[]
        tree = insert(tree, j, nothing, alloc)
        tree = insert(tree, -j, nothing, alloc)
    end
    @assert !haskey(tree, 0, alloc)
    for j in 1:n[]
        @assert haskey(tree, j, alloc)
        @assert haskey(tree, -j, alloc)
    end
    @assert !haskey(tree, n[] + 1, alloc)
    @assert !haskey(tree, -n[] - 1, alloc)
    for j in 1:n[]
        @assert haskey(tree, j, alloc)
        @assert haskey(tree, -j, alloc)
        tree = delete(tree, j, alloc)
        tree = delete(tree, -j, alloc)
        @assert !haskey(tree, j, alloc)
        @assert !haskey(tree, -j, alloc)
    end
    @assert isempty(alloc)
end

ans = nothing
for n in [100000, 1000, 10]
    println(n, " elements")

    GC.gc()

    print("  Set                                    ")
    @btime ($ans = testbase1(Ref($n)))

    GC.gc()

    print("  DataStructures.SortedSet               ")
    @btime ($ans = testbase2(Ref($n)))

    GC.gc()

    print("  DataStructures.AVLTree                 ")
    @btime ($ans = testbase3(Ref($n)))

    GC.gc()

    print("  DataStructures.RBTree                  ")
    @btime ($ans = testbase4(Ref($n)))

    GC.gc()

    print("  AVLTrees.AVLSet                        ")
    @btime ($ans = testbase5(Ref($n)))

    GC.gc()

    print("  Tree without allocator                 ")
    @btime ($ans = testbase6(Ref($n)))

    GC.gc()

    print("  with fixed allocator                   ")
    alloc = Allocator{TreeNode{Int, Int, Nothing}, Int}(2 * n)
    @btime ($ans = testalloc(Ref($n), $alloc))

    GC.gc()

    print("  with resizable allocator               ")
    alloc = Allocator{TreeNode{Int, Int, Nothing}, Int}(nothing)
    @btime ($ans = testalloc(Ref($n), $alloc))

    GC.gc()

    print("  with fixed free list allocator         ")
    alloc = FreeListAllocator{TreeNode{Int, Int, Nothing}, Int}(2 * n)
    @btime ($ans = testfree(Ref($n), $alloc))

    GC.gc()

    print("  with resizable free list allocator     ")
    alloc = FreeListAllocator{TreeNode{Int, Int, Nothing}, Int}(nothing)
    @btime ($ans = testfree(Ref($n), $alloc))

    GC.gc()

    print("  with fixed SOA allocator               ")
    store = TupleVector{TreeNode{Int, Int, Nothing}}(2 * n)
    alloc = SOAllocator{TreeNode{Int, Int, Nothing}, Int, typeof(store)}(store, 2 * n)
    @btime ($ans = testalloc(Ref($n), $alloc))

    print("  with resizable SOA allocator           ")
    store = TupleVector{TreeNode{Int, Int, Nothing}}(N)
    alloc = SOAllocator{TreeNode{Int, Int, Nothing}, Int, typeof(store)}(store, nothing)
    @btime ($ans = testalloc(Ref($n), $alloc))

    GC.gc()

    print("  with fixed free list SOA allocator     ")
    store = TupleVector{TreeNode{Int, Int, Nothing}}(2 * n)
    alloc = FreeListSOAllocator{TreeNode{Int, Int, Nothing}, Int, typeof(store)}(store, 2 * n)
    @btime ($ans = testfree(Ref($n), $alloc))

    GC.gc()

    print("  with resizable free list SOA allocator ")
    store = TupleVector{TreeNode{Int, Int, Nothing}}(N)
    alloc = FreeListSOAllocator{TreeNode{Int, Int, Nothing}, Int, typeof(store)}(store, nothing)
    @btime ($ans = testfree(Ref($n), $alloc))
end
