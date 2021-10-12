mutable struct Stack{T, I, A <: AbstractAllocator{T, I}} <: AbstractVector{T}
    alloc::A
    Stack{T, I, A}(alloc::A) where {T, I, A <: AbstractAllocator{T, I}} =
        new{T, I, A}(alloc)
end
Stack{T, I, StaticAllocator{T, I}}(n::I) where {T, I} =
    Stack{T, I, StaticAllocator{T, I}}(StaticAllocator{T, I}(n))
Stack{T, I, VariableAllocator{T, I}}() where {T, I} =
    Stack{T, I, VariableAllocator{T, I}}(VariableAllocator{T, I}())

Base.size(s::Stack{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    size(s.alloc)
Base.similar(v::Stack{T, I, A}, type::Type{T}, dims::Tuple{I}) where {T, I <: Int, A <: AbstractAllocator{T, I}} =
    Stack{T, I, A}(similar(v.alloc, type, dims))
# Base.copy(s::Stack{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
#     Stack{T, I, A}(s.alloc)

Base.push!(s::Stack{T, I, A}, t::T) where {T, I, A <: AbstractAllocator{T, I}} =
    pushend!(s.alloc, t)

Base.isempty(s::Stack{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    isempty(s.alloc)

Base.pop!(s::Stack{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    popend!(s.alloc)

Base.getindex(s::Stack{T, I, A}, i::I) where {T, I, A <: AbstractAllocator{T, I}} =
    getindex(s.alloc, i)

Base.empty!(s::Stack{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    emptyend!(s.alloc)
