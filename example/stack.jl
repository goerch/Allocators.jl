import DataStructures
import StaticArrays
using BenchmarkTools

include("../src/soalight.jl")
include("../src/allocator.jl")
include("../src/stack.jl")

function testbase(n, p)
    s = DataStructures.Stack{Tuple{Int, typeof(p)}}()
    for j in 1:n[]
        push!(s, (j, p))
    end
    for j in n[]:-1:1
        @assert j == pop!(s)[1]
    end
end

function testalloc(n, p, s)
    for j in 1:n[]
        push!(s, (j, p))
    end
    for j in n[]:-1:1
        @assert j == pop!(s)[1]
    end
    @assert isempty(s)
    emptyend!(s.alloc)
end

ans = nothing
for n in [100000, 10]
    println(n, " elements")
    for p in [1, 10, 100]
        println(" payload of ", p, " float(s)")

        Payload = StaticArrays.SVector{p ,Float64}

        GC.gc()

        print("  DataStructures.Stack           ")
        @btime ($ans = testbase(Ref($n), zeros($Payload)))

        GC.gc()

        print("  Stack with fixed allocator     ")
        alloc = Allocator{Tuple{Int, Payload}, Int}(n)
        s = Stack{Tuple{Int, Payload}, Int, Allocator{Tuple{Int, Payload}, Int}}(alloc)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $s))

        GC.gc()

        print("  Stack with resizable allocator ")
        alloc = Allocator{Tuple{Int, Payload}, Int}(nothing)
        s = Stack{Tuple{Int, Payload}, Int, Allocator{Tuple{Int, Payload}, Int}}(alloc)
        @btime ($ans = testalloc(Ref($n), zeros($Payload), $s))
    end
end
