import StaticArrays
using BenchmarkTools

include("../src/allocator.jl")
include("../src/list.jl")

function testbase(m, n, p)
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

        print("  without allocator             ")
        @btime testbase($m, $n, zeros($Payload))

        print("  fixed allocator               ")
        alloc = Allocator{ListNode{Tuple{Int, Payload}, Int}, Int}(n)
        @btime testalloc($m, $n, zeros($Payload), $alloc)

        print("  resizable allocator           ")
        alloc = Allocator{ListNode{Tuple{Int, Payload}, Int}, Int}(nothing)
        @btime testalloc($m, $n, zeros($Payload), $alloc)

        print("  fixed free list allocator     ")
        alloc = FreeListAllocator{ListNode{Tuple{Int, Payload}, Int}, Int}(n)
        @btime testfree($m, $n, zeros($Payload), $alloc)

        print("  resizable free list allocator ")
        alloc = FreeListAllocator{ListNode{Tuple{Int, Payload}, Int}, Int}(nothing)
        @btime testfree($m, $n, zeros($Payload), $alloc)
    end
end
