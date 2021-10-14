import DataStructures
import StaticArrays
using BenchmarkTools

include("../src/allocator.jl")
include("../src/queue.jl")

function testbase(m, n, p)
    q = DataStructures.Queue{Tuple{Int, typeof(p)}}()
    for i in 1:m
        for j in 1:n
            DataStructures.enqueue!(q, (j, p))
        end
        for j in 1:n
            @assert j == DataStructures.dequeue!(q)[1]
        end
    end
end

function testalloc(m, n, p, q)
    for i in 1:m
        for j in 1:n
            push!(q, (j, p))
        end
        for j in 1:n
            @assert j == pop!(q)[1]
        end
        @assert isempty(q)
        emptyend!(q.alloc)
    end
end

for (m, n) in [(10, 100000), (100000, 10)]
    println(m, " runs with ", n, " elements")
    for p in [1, 10, 100]
        println(" payload of ", p, " float(s)")

        Payload = StaticArrays.SVector{p ,Float64}

        GC.gc()

        print("  DataStructures.Queue           ")
        @btime testbase($m, $n, zeros($Payload))

        GC.gc()

        print("  Queue with fixed allocator     ")
        alloc = Allocator{Tuple{Int, Payload}, Int}(n)
        q = Queue{Tuple{Int, Payload}, Int, Allocator{Tuple{Int, Payload}, Int}}(alloc)
        @btime testalloc($m, $n, zeros($Payload), $q)

        GC.gc()

        print("  Queue with resizable allocator ")
        alloc = Allocator{Tuple{Int, Payload}, Int}(nothing)
        q = Queue{Tuple{Int, Payload}, Int, Allocator{Tuple{Int, Payload}, Int}}(alloc)
        @btime testalloc($m, $n, zeros($Payload), $q)
    end
end
