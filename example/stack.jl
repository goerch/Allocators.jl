import DataStructures
import StaticArrays
using BenchmarkTools

include("../src/allocator.jl")
include("../src/stack.jl")

function testbase(m, n, p)
    s = DataStructures.Stack{Tuple{Int, typeof(p)}}()
    for i in 1:m
        for j in 1:n
            push!(s, (j, p))
        end
        for j in n:-1:1
            @assert j == pop!(s)[1]
        end
    end
end

function testalloc(m, n, p, s)
    for i in 1:m
        for j in 1:n
            push!(s, (j, p))
        end
        for j in n:-1:1
            @assert j == pop!(s)[1]
        end
        @assert isempty(s)
        emptyend!(s.alloc)
    end
end

for (m, n) in [(10, 100000), (100000, 10)]
    println(m, " runs with ", n, " elements")
    for p in [1, 10, 100]
        println(" payload of ", p, " float(s)")

        Payload = StaticArrays.SVector{p ,Float64}

        print("  DataStructures.Stack           ")
        @btime testbase($m, $n, zeros($Payload))

        print("  Stack with fixed allocator     ")
        alloc = Allocator{Tuple{Int, Payload}, Int}(n)
        s = Stack{Tuple{Int, Payload}, Int, Allocator{Tuple{Int, Payload}, Int}}(alloc)
        @btime testalloc($m, $n, zeros($Payload), $s)

        print("  Stack with resizable allocator ")
        alloc = Allocator{Tuple{Int, Payload}, Int}(nothing)
        s = Stack{Tuple{Int, Payload}, Int, Allocator{Tuple{Int, Payload}, Int}}(alloc)
        @btime testalloc($m, $n, zeros($Payload), $s)
    end
end
