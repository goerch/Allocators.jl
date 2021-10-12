import StaticArrays
using BenchmarkTools

include("../src/allocator.jl")
include("../src/list.jl")

function buildint(n)
    l = nil()
    for i in 1:n
        l = cons(i, l)
    end
    l
end

function buildint(n, alloc)
    l = nil(alloc)
    for i in 1:n
        l = cons(i, l, alloc)
    end
    l
end

function sumint(l, n)
    s = 0
    for t in l
        s += t
    end
    @assert s == n * (n + 1) / 2
end

function sumint(l, n, alloc)
    s = 0
    for t in ListIterator((l, alloc))
        s += t
    end
    @assert s == n * (n + 1) / 2
end

function freeint(l, alloc)
    while l != 0
        car, cdr = alloc[l]
        deallocate(alloc, l)
        l = cdr
    end
end

function test1()
    for i in 1:1000
        l = buildint(1000)
        sumint(l, 1000)
    end
end

function test2a()
    alloc = StaticAllocator{ListNode{Int, Int}, Int}(1000)
    for i in 1:1000
        l = buildint(1000, alloc)
        sumint(l, 1000, alloc)
        emptyend!(alloc)
    end
end

function test2b()
    alloc = StaticFreeListAllocator{ListNode{Int, Int}, Int}(1000)
    for i in 1:1000
        l = buildint(1000, alloc)
        sumint(l, 1000, alloc)
        freeint(l, alloc)
        @assert isempty(alloc)
    end
end

function test3()
    alloc = VariableAllocator{ListNode{Int, Int}, Int}()
    for i in 1:1000
        l = buildint(1000, alloc)
        sumint(l, 1000, alloc)
        emptyend!(alloc)
    end
end

function buildsarray(n)
    l = nil()
    for i in 1:n
        l = cons(zeros(StaticArrays.SVector{3,Float64}), l)
    end
    l
end

function buildsarray(n, alloc)
    l = nil(alloc)
    for i in 1:n
        l = cons(zeros(StaticArrays.SVector{3,Float64}), l, alloc)
    end
    l
end

function sumsarray(l)
    s = zeros(StaticArrays.SVector{3,Float64})
    for t in l
        s += t
    end
end

function sumsarray(l, alloc)
    s = zeros(StaticArrays.SVector{3,Float64})
    for t in ListIterator((l, alloc))
        s += t
    end
end

function freesarray(l, alloc)
    while l != 0
        car, cdr = alloc[l]
        deallocate(alloc, l)
        l = cdr
    end
end

function test4()
    for i in 1:1000
        l = buildsarray(1000)
        sumsarray(l)
    end
end

function test5a()
    alloc = StaticAllocator{ListNode{StaticArrays.SVector{3,Float64}, Int}, Int}(1000)
    for i in 1:1000
        l = buildsarray(1000, alloc)
        sumsarray(l, alloc)
        emptyend!(alloc)
    end
end

function test5b()
    alloc = StaticFreeListAllocator{ListNode{StaticArrays.SVector{3,Float64}, Int}, Int}(1000)
    for i in 1:1000
        l = buildsarray(1000, alloc)
        sumsarray(l, alloc)
        freesarray(l, alloc)
        @assert isempty(alloc)
    end
end

function test6()
    alloc = VariableAllocator{ListNode{StaticArrays.SVector{3,Float64}, Int}, Int}()
    for i in 1:1000
        l = buildsarray(1000, alloc)
        sumsarray(l, alloc)
        emptyend!(alloc)
    end
end

#= test1()
test2a()
test2b()
test3()
test4()
test5a()
test5b()
test6() =#

@btime test1()
@btime test2a()
@btime test2b()
@btime test3()
@btime test4()
@btime test5a()
@btime test5b()
@btime test6()
