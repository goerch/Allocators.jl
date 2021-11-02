import DataStructures
import AVLTrees
import StaticArrays
using BenchmarkTools
using Profile

include("../src/soalight.jl")
include("../src/allocator.jl")
include("../src/tree_iter.jl")

function testbase1(n, p)
    tree = Dict{Int, typeof(p)}()
    for j in 1:n[]
        tree[j] = p
        tree[-j] = p
    end
    @assert !haskey(tree, 0)
    for j in 1:n[]
        @assert tree[j] === p
        @assert tree[-j] === p
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

function testbase2(n, p)
    tree = DataStructures.SortedDict{Int, typeof(p)}()
    for j in 1:n[]
        tree[j] = p
        tree[-j] = p
    end
    @assert !haskey(tree, 0)
    for j in 1:n[]
        @assert tree[j] === p
        @assert tree[-j] === p
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

# For later use
#= function testbase3(n, p)
    tree = AVLTrees.AVLDict{Int, typeof(p)}()
    for j in 1:n[]
        tree[j] = p
        tree[-j] = p
    end
    @assert !(0 in tree)
    for j in 1:n[]
        @assert tree[j] === p
        @assert tree[-j] === p
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
end =#

function testbase4(n, p)
    tree = nil()
    for j in 1:n[]
        tree = insert(tree, j, p)
        tree = insert(tree, -j, p)
    end
    @assert !haskey(tree, 0)
    for j in 1:n[]
        @assert tree[j] === p
        @assert tree[-j] === p
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

function testalloc(n, p, alloc)
    tree = nil(alloc)
    for j in 1:n[]
        tree = insert(tree, j, p, alloc)
        tree = insert(tree, -j, p, alloc)
    end
    @assert !haskey(tree, 0, alloc)
    for j in 1:n[]
        @assert getindex(tree, j, alloc) === p
        @assert getindex(tree, -j, alloc) === p
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

function testfree(n, p, alloc)
    tree = nil(alloc)
    for j in 1:n[]
        tree = insert(tree, j, p, alloc)
        tree = insert(tree, -j, p, alloc)
    end
    @assert !haskey(tree, 0, alloc)
    for j in 1:n[]
        @assert getindex(tree, j, alloc) === p
        @assert getindex(tree, -j, alloc) === p
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
for n in [100000, 10]
    println(n, " elements")

    for p in [1, 10, 100]
        println(" payload of ", p, " float(s)")

        Payload = StaticArrays.SVector{p ,Float64}

        GC.gc()

        print("  Dict                                   ")
        @btime ($ans = testbase1(Ref($n), zeros($Payload)))

        GC.gc()

        print("  DataStructures.SortedDict              ")
        @btime ($ans = testbase2(Ref($n), zeros($Payload)))

        #= GC.gc()

        print("  AVLTrees.AVLDict                       ")
        @btime ($ans = testbase3(Ref($n), zeros($Payload))) =#

        GC.gc()

        print("  Tree without allocator                 ")
        @btime ($ans = testbase4(Ref($n), zeros($Payload)))

        GC.gc()

        print("  with fixed allocator                   ")
        alloc = Allocator{TreeNode{Int, Int, Payload}, Int}(2 * n)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with resizable allocator               ")
        alloc = Allocator{TreeNode{Int, Int, Payload}, Int}(nothing)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with fixed free list allocator         ")
        alloc = FreeListAllocator{TreeNode{Int, Int, Payload}, Int}(2 * n)
        @btime ($ans = testfree(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with resizable free list allocator     ")
        alloc = FreeListAllocator{TreeNode{Int, Int, Payload}, Int}(nothing)
        @btime ($ans = testfree(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with fixed SOA allocator               ")
        store = TupleVector{TreeNode{Int, Int, Payload}}(2 * n)
        alloc = SOAllocator{TreeNode{Int, Int, Payload}, Int, typeof(store)}(store, 2 * n)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with resizable SOA allocator           ")
        store = TupleVector{TreeNode{Int, Int, Payload}}(N)
        alloc = SOAllocator{TreeNode{Int, Int, Payload}, Int, typeof(store)}(store, nothing)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with fixed free list SOA allocator     ")
        store = TupleVector{TreeNode{Int, Int, Payload}}(2 * n)
        alloc = FreeListSOAllocator{TreeNode{Int, Int, Payload}, Int, typeof(store)}(store, 2 * n)
        @btime ($ans = testfree(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with resizable free list SOA allocator ")
        store = TupleVector{TreeNode{Int, Int, Payload}}(N)
        alloc = FreeListSOAllocator{TreeNode{Int, Int, Payload}, Int, typeof(store)}(store, nothing)
        @btime ($ans = testfree(Ref($n), zeros($Payload), $alloc))
    end
end
