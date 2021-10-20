import DataStructures
import StaticArrays
using BenchmarkTools

include("../src/soalight.jl")
include("../src/allocator.jl")
include("../src/list.jl")

function testbase1(n, p)
    l = DataStructures.nil()
    for j in 1:n[]
        l = DataStructures.cons((j, p) , l)
    end
    s = 0
    while !isa(l, DataStructures.Nil)
        s += l.head[1]
        l = l.tail
    end
    @assert s == n[] * (n[] + 1) / 2
end

function testbase2(n, p)
    l = nil()
    for j in 1:n[]
        l = cons((j, p) , l)
    end
    s = 0
    while l != nothing
        s += l.car[1]
        l = l.cdr
    end
    @assert s == n[] * (n[] + 1) / 2
end

function testalloc(n, p, alloc)
    l = nil(alloc)
    for j in 1:n[]
        l = cons((j, p), l, alloc)
    end
    s = 0
    while l != 0
        car, cdr = alloc[l]
        s += car[1]
        l = cdr
    end
    @assert s == n[] * (n[] + 1) / 2
    emptyend!(alloc)
end

function testfree(n, p, alloc)
    l = nil(alloc)
    for j in 1:n[]
        l = cons((j, p), l, alloc)
    end
    s = 0
    while l != 0
        car, cdr = alloc[l]
        s += car[1]
        deallocate(l, alloc)
        l = cdr
    end
    @assert s == n[] * (n[] + 1) / 2
    @assert isempty(alloc)
end

ans = nothing
for n in [100000, 10]
    println(n, " elements")
    for p in [1, 10, 100]
        println(" payload of ", p, " float(s)")

        Payload = StaticArrays.SVector{p, Float64}

        GC.gc()

        print("  DataStructures.List                    ")
        @btime ($ans = testbase1(Ref($n), zeros($Payload)))

        GC.gc()

        print("  List without allocator                 ")
        @btime ($ans = testbase2(Ref($n), zeros($Payload)))

        GC.gc()

        print("  with fixed allocator                   ")
        alloc = Allocator{ListNode{Tuple{Int, Payload}, Int}, Int}(n)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with resizable allocator               ")
        alloc = Allocator{ListNode{Tuple{Int, Payload}, Int}, Int}(nothing)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with fixed free list allocator         ")
        alloc = FreeListAllocator{ListNode{Tuple{Int, Payload}, Int}, Int}(n)
        @btime ($ans = testfree(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with resizable free list allocator     ")
        alloc = FreeListAllocator{ListNode{Tuple{Int, Payload}, Int}, Int}(nothing)
        @btime ($ans = testfree(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with fixed SOA allocator               ")
        store = TupleVector{ListNode{Tuple{Int, Payload}, Int}}(n)
        alloc = SOAllocator{ListNode{Tuple{Int, Payload}, Int}, Int, typeof(store)}(store, n)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $alloc))
        GC.gc()

        print("  with resizable SOA allocator           ")
        store = TupleVector{ListNode{Tuple{Int, Payload}, Int}}(N)
        alloc = SOAllocator{ListNode{Tuple{Int, Payload}, Int}, Int, typeof(store)}(store, nothing)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with fixed free list SOA allocator     ")
        store = TupleVector{ListNode{Tuple{Int, Payload}, Int}}(n)
        alloc = FreeListSOAllocator{ListNode{Tuple{Int, Payload}, Int}, Int, typeof(store)}(store, n)
        @btime ($ans = testfree(Ref($n), zeros($Payload), $alloc))

        GC.gc()

        print("  with resizable free list SOA allocator ")
        store = TupleVector{ListNode{Tuple{Int, Payload}, Int}}(N)
        alloc = FreeListSOAllocator{ListNode{Tuple{Int, Payload}, Int}, Int, typeof(store)}(store, nothing)
        @btime ($ans = testfree(Ref($n), zeros($Payload), $alloc))
    end
end
