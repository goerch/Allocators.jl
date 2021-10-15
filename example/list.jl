import DataStructures
import StaticArrays
using BenchmarkTools

include("../src/soalight.jl")
include("../src/allocator.jl")
include("../src/list.jl")

function testbase1(m, n, p)
    for i in 1:m
        l = DataStructures.nil()
        for j in 1:n
            l = DataStructures.cons((j, p) , l)
        end
        s = 0
        while !isa(l, DataStructures.Nil)
            s += l.head[1]
            l = l.tail
        end
        @assert s == n * (n + 1) / 2
    end
end

function testbase2(m, n, p)
    for i in 1:m
        l = nil()
        for j in 1:n
            l = cons((j, p) , l)
        end
        s = 0
        while l != nothing
            s += l.car[1]
            l = l.cdr
        end
        @assert s == n * (n + 1) / 2
    end
end

function testalloc(m, n, p, alloc)
    for i in 1:m
        l = nil(alloc)
        for j in 1:n
            l = cons((j, p), l, alloc)
        end
        s = 0
        while l != 0
            car, cdr = alloc[l]
            s += car[1]
            l = cdr
        end
        @assert s == n * (n + 1) / 2
        emptyend!(alloc)
    end
end

function testfree(m, n, p, alloc)
    for i in 1:m
        l = nil(alloc)
        for j in 1:n
            l = cons((j, p), l, alloc)
        end
        s = 0
        while l != 0
            car, cdr = alloc[l]
            s += car[1]
            deallocate(l, alloc)
            l = cdr
        end
        @assert s == n * (n + 1) / 2
        @assert isempty(alloc)
    end
end

for (m, n) in [(10, 100000), (100000, 10)]
    println(m, " runs with ", n, " elements")
    for p in [1, 10, 100]
        println(" payload of ", p, " float(s)")

        Payload = StaticArrays.SVector{p, Float64}

        GC.gc()

        print("  DataStructures.List                    ")
        @btime testbase1($m, $n, zeros($Payload))

        GC.gc()

        print("  List without allocator                 ")
        @btime testbase2($m, $n, zeros($Payload))

        GC.gc()

        print("  with fixed allocator                   ")
        alloc = Allocator{ListNode{Tuple{Int, Payload}, Int}, Int}(n)
        @btime testalloc($m, $n, zeros($Payload), $alloc)

        GC.gc()

        print("  with resizable allocator               ")
        alloc = Allocator{ListNode{Tuple{Int, Payload}, Int}, Int}(nothing)
        @btime testalloc($m, $n, zeros($Payload), $alloc)

        GC.gc()

        print("  with fixed free list allocator         ")
        alloc = FreeListAllocator{ListNode{Tuple{Int, Payload}, Int}, Int}(n)
        @btime testfree($m, $n, zeros($Payload), $alloc)

        GC.gc()

        print("  with resizable free list allocator     ")
        alloc = FreeListAllocator{ListNode{Tuple{Int, Payload}, Int}, Int}(nothing)
        @btime testfree($m, $n, zeros($Payload), $alloc)

        GC.gc()

        print("  with fixed SOA allocator               ")
        store = TupleVector{ListNode{Tuple{Int, Payload}, Int}}(n)
        alloc = SOAllocator{ListNode{Tuple{Int, Payload}, Int}, Int, typeof(store)}(store, n)
        @btime testalloc($m, $n, zeros($Payload), $alloc)
        GC.gc()

        print("  with resizable SOA allocator           ")
        store = TupleVector{ListNode{Tuple{Int, Payload}, Int}}(N)
        alloc = SOAllocator{ListNode{Tuple{Int, Payload}, Int}, Int, typeof(store)}(store, nothing)
        @btime testalloc($m, $n, zeros($Payload), $alloc)

        GC.gc()

        print("  with fixed free list SOA allocator     ")
        store = TupleVector{ListNode{Tuple{Int, Payload}, Int}}(n)
        alloc = FreeListSOAllocator{ListNode{Tuple{Int, Payload}, Int}, Int, typeof(store)}(store, n)
        @btime testfree($m, $n, zeros($Payload), $alloc)

        GC.gc()

        print("  with resizable free list SOA allocator ")
        store = TupleVector{ListNode{Tuple{Int, Payload}, Int}}(N)
        alloc = FreeListSOAllocator{ListNode{Tuple{Int, Payload}, Int}, Int, typeof(store)}(store, nothing)
        @btime testfree($m, $n, zeros($Payload), $alloc)
    end
end
