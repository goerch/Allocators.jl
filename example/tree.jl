import DataStructures
using BenchmarkTools

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
            # @assert haskey(tree, j, alloc)
            tree = delete(tree, j, alloc)
            # @assert !haskey(tree, j, alloc)
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
            # @assert haskey(tree, j, alloc)
            tree = delete(tree, j, alloc)
            # @assert !haskey(tree, j, alloc)
        end
        @assert isempty(alloc)
    end
end

for (m, n) in [(10, 100000), (1000, 1000), (100000, 10)]
    println(m, " runs with ", n, " elements")

    print("  Set                           ")
    @btime testbase1($m, $n)

    print("  DataStructures.SortedSet      ")
    @btime testbase2($m, $n)

    print("  without allocator             ")
    @btime testbase3($m, $n)

    print("  fixed allocator               ")
    alloc = Allocator{TreeNode{Int, Int}, Int}(n)
    @btime testalloc($m, $n, $alloc)

    print("  resizable allocator           ")
    alloc = Allocator{TreeNode{Int, Int}, Int}(nothing)
    @btime testalloc($m, $n, $alloc)

    print("  fixed free list allocator     ")
    alloc = FreeListAllocator{TreeNode{Int, Int}, Int}(n)
    @btime testfree($m, $n, $alloc)

    print("  resizable free list allocator ")
    alloc = FreeListAllocator{TreeNode{Int, Int}, Int}(nothing)
    @btime testfree($m, $n, $alloc)
end
