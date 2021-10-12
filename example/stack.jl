import DataStructures
using BenchmarkTools

include("../src/allocator.jl")
include("../src/stack.jl")

function buildint!(s, n)
    for i in 1:n
        push!(s, i)
    end
end

function checkint(s, n)
    for i in n:-1:1
        @assert i == pop!(s)
    end
end

function test1()
    s = DataStructures.Stack{Int}()
    for i in 1:1000
        buildint!(s, 1000)
        checkint(s, 1000)
        # empty!(s)
        # s = DataStructures.Stack{Int}()
    end
end

const StaticStack = Stack{Int, Int, StaticAllocator{Int, Int}}

function test2()
    s = StaticStack(1000)
    for i in 1:1000
        buildint!(s, 1000)
        checkint(s, 1000)
        # empty!(s)
        # s = StaticStack(1000)
    end
end

const VariableStack = Stack{Int, Int, VariableAllocator{Int, Int}}

function test3()
    s = VariableStack()
    for i in 1:1000
        buildint!(s, 1000)
        checkint(s, 1000)
        # empty!(s)
        # s = VariableStack()
    end
end

#= test1()
test2()
test3() =#

@btime test1()
@btime test2()
@btime test3()
