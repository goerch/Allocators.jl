import DataStructures
import AVLTrees
using BenchmarkTools

include("../src/soalight.jl")
include("../src/allocator.jl")
include("../src/tree.jl")

function testbase1(m, n)
    tree = Set{Int}()
    for i in 1:m
        for j in 1:n
            push!(tree, j)
        end
        for j in 1:n
            @assert j in tree
        end
        for j in 1:n
            pop!(tree, j)
        end
    end
end

function testbase2(m, n)
    tree = DataStructures.SortedSet{Int}()
    for i in 1:m
        for j in 1:n
            push!(tree, j)
        end
        for j in 1:n
            @assert haskey(tree, j)
        end
        for j in 1:n
            pop!(tree, j)
        end
    end
end

function testbase3(m, n)
    tree = DataStructures.AVLTree{Int}()
    for i in 1:m
        for j in 1:n
            insert!(tree, j)
        end
        for j in 1:n
            @assert haskey(tree, j)
        end
        for j in 1:n
            delete!(tree, j)
        end
    end
end

function testbase4(m, n)
    tree = DataStructures.RBTree{Int}()
    for i in 1:m
        for j in 1:n
            insert!(tree, j)
        end
        for j in 1:n
            @assert haskey(tree, j)
        end
        for j in 1:n
            delete!(tree, j)
        end
    end
end

function testbase5(m, n)
    tree = AVLTrees.AVLSet{Int}()
    for i in 1:m
        for j in 1:n
            push!(tree, j)
        end
        for j in 1:n
            @assert j in tree
        end
        for j in 1:n
            delete!(tree, j)
        end
    end
end

function testbase6(m, n)
    for i in 1:m
        tree = nil()
        for j in 1:n
            tree = insert(tree, j)
        end
        for j in 1:n
            @assert haskey(tree, j)
        end
        for j in 1:n
            @assert haskey(tree, j)
            tree = delete(tree, j)
            @assert !haskey(tree, j)
        end
    end
end

function testalloc(m, n, alloc)
    for i in 1:m
        tree = nil(alloc)
        for j in 1:n
            tree = insert(tree, j, alloc)
        end
        for j in 1:n
            @assert haskey(tree, j, alloc)
        end
        for j in 1:n
            @assert haskey(tree, j, alloc)
            tree = delete(tree, j, alloc)
            @assert !haskey(tree, j, alloc)
        end
        emptyend!(alloc)
    end
end

function testfree(m, n, alloc)
    for i in 1:m
        tree = nil(alloc)
        for j in 1:n
            tree = insert(tree, j, alloc)
        end
        for j in 1:n
            @assert haskey(tree, j, alloc)
        end
        for j in 1:n
            @assert haskey(tree, j, alloc)
            tree = delete(tree, j, alloc)
            @assert !haskey(tree, j, alloc)
        end
        @assert isempty(alloc)
    end
end

for (m, n) in [(10, 100000), (1000, 1000), (100000, 10)]
    println(m, " runs with ", n, " elements")

    #= GC.gc()

    print("  Set                                    ")
    @btime testbase1($m, $n)

    GC.gc()

    print("  DataStructures.SortedSet               ")
    @btime testbase2($m, $n) =#

    GC.gc()

    print("  DataStructures.AVLTree                 ")
    @btime testbase3($m, $n)

    GC.gc()

    print("  DataStructures.RBTree                  ")
    @btime testbase4($m, $n)

    GC.gc()

    print("  AVLTrees.AVLSet                        ")
    @btime testbase5($m, $n)

    GC.gc()

    print("  Tree without allocator                 ")
    @btime testbase6($m, $n)

    GC.gc()

    print("  with fixed allocator                   ")
    alloc = Allocator{TreeNode{Int, Int}, Int}(n)
    @btime testalloc($m, $n, $alloc)

    GC.gc()

    print("  with resizable allocator               ")
    alloc = Allocator{TreeNode{Int, Int}, Int}(nothing)
    @btime testalloc($m, $n, $alloc)

    GC.gc()

    print("  with fixed free list allocator         ")
    alloc = FreeListAllocator{TreeNode{Int, Int}, Int}(n)
    @btime testfree($m, $n, $alloc)

    GC.gc()

    print("  with resizable free list allocator     ")
    alloc = FreeListAllocator{TreeNode{Int, Int}, Int}(nothing)
    @btime testfree($m, $n, $alloc)

    GC.gc()

    print("  with fixed SOA allocator               ")
    store = TupleVector{TreeNode{Int, Int}}(n)
    alloc = SOAllocator{TreeNode{Int, Int}, Int, typeof(store)}(store, n)
    @btime testalloc($m, $n, $alloc)

    print("  with resizable SOA allocator           ")
    store = TupleVector{TreeNode{Int, Int}}(N)
    alloc = SOAllocator{TreeNode{Int, Int}, Int, typeof(store)}(store, nothing)
    @btime testalloc($m, $n, $alloc)

    GC.gc()

    print("  with fixed free list SOA allocator     ")
    store = TupleVector{TreeNode{Int, Int}}(n)
    alloc = FreeListSOAllocator{TreeNode{Int, Int}, Int, typeof(store)}(store, n)
    @btime testfree($m, $n, $alloc)

    GC.gc()

    print("  with resizable free list SOA allocator ")
    store = TupleVector{TreeNode{Int, Int}}(N)
    alloc = FreeListSOAllocator{TreeNode{Int, Int}, Int, typeof(store)}(store, nothing)
    @btime testfree($m, $n, $alloc)
end
