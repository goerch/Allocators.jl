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

function test1()
    for i in 1:1000
        l = buildint(1000)
        sumint(l, 1000)
    end
end

function test2()
    alloc = StaticAllocator{ListNode{Int, Int}, Int}(1000)
    for i in 1:1000
        l = buildint(1000, alloc)
        sumint(l, 1000, alloc)
        emptyend!(alloc)
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

function buildstring(n)
    l = nil()
    for i in 1:n
        l = cons(string(i), l)
    end
    l
end

function buildstring(n, alloc)
    l = nil(alloc)
    for i in 1:n
        l = cons(string(i), l, alloc)
    end
    l
end

function sumstring(l, n)
    s = 0
    for t in l
        s += parse(Int, t)
    end
    @assert s == n * (n + 1) / 2
end

function sumstring(l, n, alloc)
    s = 0
    for t in ListIterator((l, alloc))
        s += parse(Int, t)
    end
    @assert s == n * (n + 1) / 2
end

function test4()
    for i in 1:1000
        l = buildstring(1000)
        sumstring(l, 1000)
    end
end

function test5()
    alloc = StaticAllocator{ListNode{String, Int}, Int}(1000)
    for i in 1:1000
        l = buildstring(1000, alloc)
        sumstring(l, 1000, alloc)
        emptyend!(alloc)
    end
end

function test6()
    alloc = VariableAllocator{ListNode{String, Int}, Int}()
    for i in 1:1000
        l = buildstring(1000, alloc)
        sumstring(l, 1000, alloc)
        emptyend!(alloc)
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
