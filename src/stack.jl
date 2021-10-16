mutable struct Stack{T, I, A <: AbstractAllocator{T, I}} # <: AbstractVector{T}
    alloc::A
    Stack{T, I, A}(alloc::A) where {T, I, A <: AbstractAllocator{T, I}} =
        new{T, I, A}(alloc)
end

Base.push!(s::Stack{T, I, A}, t::T) where {T, I, A <: AbstractAllocator{T, I}} =
    allocateend!(s.alloc, t)

Base.isempty(s::Stack{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    isempty(s.alloc)

function Base.pop!(s::Stack{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}}
    t = s.alloc[s.alloc.last]
    deallocateend!(s.alloc)
    t
end
