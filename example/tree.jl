import DataStructures
using BenchmarkTools

include("../src/allocator.jl")
include("../src/stack.jl")
include("../src/tree.jl")

function build(n)
    tree = nil()
    for i in 1:n
        tree = insert(tree, i)
    end
    tree
end

function find(n, tree)
    @assert !haskey(tree, 0)
    for i in 1:n
        @assert haskey(tree, i)
    end
    @assert !haskey(tree, n + 1)
end

function destroy(n, tree)
    for i in 1:n
        @assert haskey(tree, i)
        tree = delete(tree, i)
        @assert !haskey(tree, i)
    end
    tree
end

function build(n, alloc)
    tree = nil(alloc)
    for i in 1:n
        tree = insert(tree, i, alloc)
    end
    tree
end

function find(n, tree, alloc)
    @assert !haskey(tree, 0, alloc)
    for i in 1:n
        @assert haskey(tree, i, alloc)
    end
    @assert !haskey(tree, n + 1, alloc)
end

function destroy(n, tree, alloc)
    for i in 1:n
        @assert haskey(tree, i, alloc)
        tree = delete(tree, i, alloc)
        @assert !haskey(tree, i, alloc)
    end
    tree
end

const test_M = 1000
const test_N = 1000

function test10()
    tree = Set{Int}()
    for i in 1:test_M
        for j in 1:test_N
            push!(tree, j)
        end
        for j in 1:test_N
            @assert j in tree
        end
        for j in 1:test_N
            @assert j in tree
            pop!(tree, j)
            @assert !(j in tree)
        end
        empty!(tree)
        # tree = Set{Int}()
    end
end

function test11()
    tree = DataStructures.SortedSet{Int}()
    for i in 1:test_M
        for j in 1:test_N
            push!(tree, j)
        end
        for j in 1:test_N
            @assert haskey(tree, j)
        end
        for j in 1:test_N
            @assert haskey(tree, j)
            pop!(tree, j)
            @assert !haskey(tree, j)
        end
        empty!(tree)
        # tree = DataStructures.SortedSet{Int}()
    end
end

function test12()
    for i in 1:test_M
        tree = build(test_N)
        find(test_N, tree)
        tree = destroy(test_N, tree)
        @assert tree == nothing
    end
end

function test13()
    alloc = StaticAllocator{TreeNode{Int, Int}, Int}(test_N)
    for i in 1:test_M
        tree = build(test_N, alloc)
        find(test_N, tree, alloc)
        tree = destroy(test_N, tree, alloc)
        @assert tree == 0
        emptyend!(alloc)
    end
end

function test14()
    alloc = VariableAllocator{TreeNode{Int, Int}, Int}()
    for i in 1:test_M
        tree = build(test_N, alloc)
        find(test_N, tree, alloc)
        tree = destroy(test_N, tree, alloc)
        @assert tree == 0
        emptyend!(alloc)
    end
end

#= test10()
test11()
test12()
test13()
test14() =#

GC.gc()
@btime test10()
GC.gc()
@btime test11()
GC.gc()
@btime test12()
GC.gc()
@btime test13()
GC.gc()
@btime test14()
GC.gc()

#= using Profile
Profile.clear()
test12()
@profile test12()
# Profile.print()
Juno.profiler() =#
