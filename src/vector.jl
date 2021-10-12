struct AllocatedVector{T, I, A <: AbstractAllocator{T, I}} <: AbstractVector{T}
    alloc::A
    AllocatedVector{T, I, A}(alloc::A) where {T, I, A <: AbstractAllocator{T, I}} =
        new{T, I, A}(alloc)
end
AllocatedVector{T, I, StaticAllocator{T, I}}(n::I) where {T, I} =
    AllocatedVector{T, I, StaticAllocator{T, I}}(StaticAllocator{T, I}(n))
AllocatedVector{T, I, VariableAllocator{T, I}}() where {T, I} =
    AllocatedVector{T, I, VariableAllocator{T, I}}(VariableAllocator{T, I}())
AllocatedVector{T, I, VariableAllocator{T, I}}(n::I) where {T, I} =
    AllocatedVector{T, I, VariableAllocator{T, I}}(VariableAllocator{T, I}())

Base.size(v::AllocatedVector{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    size(v.alloc)
Base.similar(v::AllocatedVector{T, I, A}, type::Type{T}, dims::Tuple{I}) where {T, I <: Int, A <: AbstractAllocator{T, I}} =
    AllocatedVector{T, I, A}(similar(v.alloc, type, dims))
# Base.copy(v::AllocatedVector{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
#    AllocatedVector{T, I, A}(v.alloc)

Base.push!(v::AllocatedVector{T, I, A}, t::T) where {T, I, A <: AbstractAllocator{T, I}} =
    pushend!(v.alloc, t)

Base.getindex(v::AllocatedVector{T, I, A}, i::I) where {T, I, A <: AbstractAllocator{T, I}} =
    getindex(v.alloc, i)
Base.setindex!(v::AllocatedVector{T, I, A}, t::T, i::I) where {T, I, A <: AbstractAllocator{T, I}} =
    setindex!(v.alloc, t, i)

Base.empty!(v::AllocatedVector{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    emptyend!(v.alloc)

Base.iterate(v::AllocatedVector{T, I, A}, current) where {T, I, A <: AbstractAllocator{T, I}} =
    v.alloc.last < current ? nothing : (v.alloc[current], current + 1)
Base.iterate(v::AllocatedVector{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    v.alloc.last < 1 ? nothing : (v.alloc[1], 2)
