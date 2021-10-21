using BenchmarkTools
using Profile

include("../src/tuple.jl")
include("../src/soalight.jl")
include("../src/allocator.jl")
include("../src/tree.jl")

function testbase()
    tree = nil()
    for j in 1:10000000
        i = rand(1:100000)
        # println("insert ", i, " ", haskey(tree, i))
        tree = insert(tree, i)
        i = rand(1:100000)
        # println("delete ", i, " ", haskey(tree, i))
        tree = delete(tree, i)
        if j % 1000 == 0
            print(".")
        end
    end
end

function testalloc()
    alloc = FreeListAllocator{TreeNode{Int, Int}, Int}(nothing)
    tree = nil(alloc)
    for j in 1:10000000
        i = rand(1:100000)
        # println("insert ", i, " ", haskey(tree, i, alloc))
        tree = insert(tree, i, alloc)
        i = rand(1:100000)
        # println("delete ", i, " ", haskey(tree, i, alloc))
        tree = delete(tree, i, alloc)
        if j % 1000 == 0
            print(".")
        end
    end
end
