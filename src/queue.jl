struct Queue{T, I, A <: AbstractAllocator{T, I}}
    alloc::A
    function Queue{T, I, A}(alloc::A) where {T, I, A <: AbstractAllocator{T, I}}
        new{T, I, A}(alloc)
    end
end

Base.push!(q::Queue{T, I, A}, t::T) where {T, I, A <: AbstractAllocator{T, I}} =
    allocateend!(q.alloc, t)

Base.isempty(q::Queue{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    isempty(q.alloc)

function Base.pop!(q::Queue{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}}
    t = q.alloc[q.alloc.first]
    deallocatebegin!(q.alloc)
    t
end

Base.empty!(q::Queue{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    emptyend!(q.alloc)
