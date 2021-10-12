using BenchmarkTools

include("../src/allocator.jl")
include("../src/vector.jl")

function buildint!(v, n)
    for i in 1:n
        push!(v, i)
    end
end

function setint!(v, n)
    for i in 1:n
        v[i] = i
    end
end

function sumint(v, n)
    s = 0
    for t in v
        s += t
    end
    @assert s == n * (n + 1) / 2
end

function test1()
    v = Int[]
    for i in 1:1000
        buildint!(v, 1000)
        sumint(v, 1000)
        # empty!(v)
        v = Int[]
    end
end

function test2()
    v = Int[]
    resize!(v, 1000)
    for i in 1:1000
        setint!(v, 1000)
        sumint(v, 1000)
        # empty!(v)
        v = Int[]
        resize!(v, 1000)
    end
end

const StaticVector = AllocatedVector{Int, Int, StaticAllocator{Int, Int}}

function test3()
    v = StaticVector(1000)
    for i in 1:1000
        buildint!(v, 1000)
        sumint(v, 1000)
        # empty!(v)
        v = StaticVector(1000)
    end
end

const VariableVector = AllocatedVector{Int, Int, VariableAllocator{Int, Int}}

function test4()
    v = VariableVector()
    for i in 1:1000
        buildint!(v, 1000)
        sumint(v, 1000)
        # empty!(v)
        v = VariableVector()
    end
end

#= test1()
test2()
test3()
test4() =#

@btime test1()
@btime test2()
@btime test3()
@btime test4()
