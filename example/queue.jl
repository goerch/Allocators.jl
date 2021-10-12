import DataStructures
using BenchmarkTools

include("../src/allocator.jl")
include("../src/list.jl")
include("../src/queue.jl")

function buildint!(q, n)
    for i in 1:n
        push!(q, i)
    end
end

function checkint(q, n)
    for i in 1:n
        @assert i == pop!(q)
    end
end

function test1()
    q = DataStructures.Queue{Int}()
    for i in 1:1000
        for j in 1:1000
            DataStructures.enqueue!(q, j)
        end
        for j in 1:1000
            @assert j == DataStructures.dequeue!(q)
        end
        empty!(q)
        # q = DataStructures.Stack{Int}()
    end
end

function test2()
    q = FunQueue{Int}(0)
    for i in 1:1000
        buildint!(q, 1000)
        checkint(q, 1000)
        empty!(q)
        # q = FunQueue{Int}(0)
    end
end

const StaticFunQueue = AllocatedFunQueue{Int, Int, StaticAllocator{ListNode{Int, Int}, Int}}

function test3()
    q = StaticFunQueue(1000)
    for i in 1:1000
        buildint!(q, 1000)
        checkint(q, 1000)
        empty!(q)
        # q = StaticFunQueue(1000)
    end
end

const VariableFunQueue = AllocatedFunQueue{Int, Int, VariableAllocator{ListNode{Int, Int}, Int}}

function test4()
    q = VariableFunQueue()
    for i in 1:1000
        buildint!(q, 1000)
        checkint(q, 1000)
        empty!(q)
        # q = VariableFunQueue()
    end
end

const StaticQueue = Queue{Int, Int, StaticAllocator{Int, Int}}

function test5()
    q = StaticQueue(1000)
    for i in 1:1000
        buildint!(q, 1000)
        checkint(q, 1000)
        empty!(q)
        # q = StaticQueue(1000)
    end
end

const VariableQueue = Queue{Int, Int, VariableAllocator{Int, Int}}

function test6()
    q = VariableQueue()
    for i in 1:1000
        for j in 1:1000
            push!(q, j)
        end
        for j in 1:1000
            @assert j == pop!(q)
        end
        empty!(q)
        # q = VariableQueue()
    end
end

#= test1()
test2()
test3()
test4()
test5()
test6() =#

@btime test1()
@btime test2()
@btime test3()
@btime test4()
@btime test5()
@btime test6()
