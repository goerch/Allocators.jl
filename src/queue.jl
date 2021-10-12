mutable struct FunQueue{T}
    pop::List{T}
    push::List{T}
    function FunQueue{T}(t) where T
        new{T}(nothing, nothing)
    end
end

function Base.push!(q::FunQueue{T}, t::T) where T
    q.push = cons(t, q.push)
end

function Base.pop!(q::FunQueue{T}) where T
    if q.pop == nothing
        q.pop = reverse(q.push)
        q.push = nothing
    end
    car = q.pop.car
    q.pop = q.pop.cdr
    car
end

Base.isempty(q::FunQueue{T}) where T =
    q.push == nothing && q.pop == nothing

function Base.empty!(q::FunQueue{T}) where T
    q.pop = nothing
    q.push = nothing
end

mutable struct AllocatedFunQueue{T, I, A <: AbstractAllocator{Tuple{T, I}, I}}
    alloc::A
    pop::I
    push::I
    AllocatedFunQueue{T, I, A}(alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I}, I}} =
        new{T, I, A}(alloc, 0, 0)
end
AllocatedFunQueue{T, I, StaticAllocator{Tuple{T, I}, I}}(n::I) where {T, I} =
    AllocatedFunQueue{T, I, StaticAllocator{Tuple{T, I}, I}}(StaticAllocator{Tuple{T, I}, I}(n))
AllocatedFunQueue{T, I, VariableAllocator{Tuple{T, I}, I}}() where {T, I} =
    AllocatedFunQueue{T, I, VariableAllocator{Tuple{T, I}, I}}(VariableAllocator{Tuple{T, I}, I}())

function Base.push!(q::AllocatedFunQueue{T, I, A}, t::T) where {T, I, A <: AbstractAllocator{Tuple{T, I}, I}}
    q.push = cons(t, q.push, q.alloc)
end

Base.isempty(q::AllocatedFunQueue{T, I, A}) where {T, I, A <: AbstractAllocator{Tuple{T, I}, I}} =
    isempty(q.alloc)

function Base.pop!(q::AllocatedFunQueue{T, I, A}) where {T, I, A <: AbstractAllocator{Tuple{T, I}, I}}
    if q.pop == 0
        q.pop = reverse(ListIterator((q.push, q.alloc))).list[1]
        q.push = 0
    end
    car, cdr = q.alloc[q.pop[1]]
    q.pop = cdr
    car
end

function Base.empty!(q::AllocatedFunQueue{T, I, A}) where {T, I, A <: AbstractAllocator{Tuple{T, I}, I}}
    emptyend!(q.alloc)
    q.pop = 0
    q.push = 0
end

mutable struct Queue{T, I, A <: AbstractAllocator{T, I}}
    alloc::A
    function Queue{T, I, A}(alloc::A) where {T, I, A <: AbstractAllocator{T, I}}
        new{T, I, A}(alloc)
    end
end
Queue{T, I, StaticAllocator{T, I}}(n::I) where {T, I} =
    Queue{T, I, StaticAllocator{T, I}}(StaticAllocator{T, I}(n))
Queue{T, I, VariableAllocator{T, I}}() where {T, I} =
    Queue{T, I, VariableAllocator{T, I}}(VariableAllocator{T, I}())

Base.size(q::Queue{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    size(q.alloc)
Base.similar(q::Queue{T, I, A}, type::Type{T}, dims::Tuple{I}) where {T, I <: Int, A <: AbstractAllocator{T, I}} =
    Queue{T, I, A}(similar(v.alloc, type, dims))
# Base.copy(q::Queue{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
#     Queue{T, I, A}(q.alloc)

Base.push!(q::Queue{T, I, A}, t::T) where {T, I, A <: AbstractAllocator{T, I}} =
    pushend!(q.alloc, t)

Base.isempty(q::Queue{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    isempty(q.alloc)

Base.pop!(q::Queue{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    popbegin!(q.alloc)

Base.empty!(q::Queue{T, I, A}) where {T, I, A <: AbstractAllocator{T, I}} =
    emptyend!(q.alloc)
