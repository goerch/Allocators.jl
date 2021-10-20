import DataStructures
import StaticArrays
using BenchmarkTools

include("../src/soalight.jl")
include("../src/allocator.jl")
include("../src/queue.jl")

function testbase(n, p)
    q = DataStructures.Queue{Tuple{Int, typeof(p)}}()
    for j in 1:n[]
        DataStructures.enqueue!(q, (j, p))
    end
    for j in 1:n[]
        @assert j == DataStructures.dequeue!(q)[1]
    end
end

function testalloc(n, p, q)
    for j in 1:n[]
        push!(q, (j, p))
    end
    for j in 1:n[]
        @assert j == pop!(q)[1]
    end
    @assert isempty(q)
    emptyend!(q.alloc)
end

ans = nothing
for n in [100000, 10]
    println(n, " elements")
    for p in [1, 10, 100]
        println(" payload of ", p, " float(s)")

        Payload = StaticArrays.SVector{p ,Float64}

        GC.gc()

        print("  DataStructures.Queue           ")
        @btime ($ans = testbase(Ref($n), zeros($Payload)))

        GC.gc()

        print("  Queue with fixed allocator     ")
        alloc = Allocator{Tuple{Int, Payload}, Int}(n)
        q = Queue{Tuple{Int, Payload}, Int, Allocator{Tuple{Int, Payload}, Int}}(alloc)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $q))

        GC.gc()

        print("  Queue with resizable allocator ")
        alloc = Allocator{Tuple{Int, Payload}, Int}(nothing)
        q = Queue{Tuple{Int, Payload}, Int, Allocator{Tuple{Int, Payload}, Int}}(alloc)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $q))
    end
end
