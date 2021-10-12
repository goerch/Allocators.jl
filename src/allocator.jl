abstract type AbstractAllocator{T, I} end
abstract type AbstractFreeListAllocator{T, I} <: AbstractAllocator{T, I} end

abstract type Direction end
struct Forward <: Direction end
struct Backward <: Direction end

mutable struct StaticAllocator{T, I} <: AbstractAllocator{T, I}
    direction::Direction
    store::Vector{T}
    first::I
    last::I
    StaticAllocator{T, I}(n, direction::Forward, reserve=0) where {T, I} =
        new{T, I}(direction, Vector{T}(undef, n), 1, reserve)
    StaticAllocator{T, I}(n, direction::Backward, reserve=0) where {T, I} =
        new{T, I}(direction, Vector{T}(undef, n), n + 1 - reserve, n)
    StaticAllocator{T, I}(direction, store, first, last) where {T, I} =
        new{T, I}(direction, store, first, last)
end
StaticAllocator{T, I}(n::I) where {T, I} = StaticAllocator{T, I}(n, Forward())

Base.size(alloc::StaticAllocator{T, I}) where {T, I} =
    (alloc.last - alloc.first + 1,)
Base.similar(alloc::StaticAllocator{T, I}, ::Type{T}, dims::Tuple{I}) where {T, I} =
    StaticAllocator{T, I}(dims[1], alloc.direction, dims[1])
# Base.copy(alloc::StaticAllocator{T, I}) where {T, I} =
#     StaticAllocator{T, A}(alloc.direction, alloc.n, copy(alloc.store), alloc.first, alloc.last)

function pushend!(alloc::StaticAllocator{T, I}, t::T) where {T, I}
    alloc.last += 1
    alloc.store[alloc.last] = t
    alloc.last
end
function pushbegin!(alloc::StaticAllocator{T, I}, t::T) where {T, I}
    alloc.first -= 1
    alloc.store[alloc.first] = t
    alloc.first
end

Base.isempty(alloc::StaticAllocator{T, I}) where {T, I} =
    alloc.first == alloc.last + 1

function popend!(alloc::StaticAllocator{T, I}) where {T, I}
    t = alloc.store[alloc.last]
    alloc.last -= 1
    t
end
function popbegin!(alloc::StaticAllocator{T, I}) where {T, I}
    t = alloc.store[alloc.first]
    alloc.first += 1
    t
end

Base.getindex(alloc::StaticAllocator{T}, i::I) where {T, I} =
    alloc.store[i]
Base.setindex!(alloc::StaticAllocator{T, I}, t::T, i::I)  where {T, I} =
    alloc.store[i] = t

function emptyend!(alloc::StaticAllocator{T, I}) where {T, I}
    alloc.first = 1
    alloc.last = 0
end
function emptybegin!(alloc::StaticAllocator{T, I}) where {T, I}
    alloc.first = alloc.n + 1
    alloc.last = alloc.n
end

mutable struct FreeList{I}
    store::Vector{I}
    last::I
    FreeList{I}(n) where I =
        new{I}(Vector{I}(undef, n), 0)
end

function Base.push!(freelist::FreeList{I}, i::I) where I
    freelist.last += 1
    freelist.store[freelist.last] = i
end

Base.isempty(freelist::FreeList{I}) where I =
    freelist.last == 0

function Base.pop!(freelist::FreeList{I}) where I
    i = freelist.store[freelist.last]
    freelist.last -= 1
    i
end

mutable struct StaticFreeListAllocator{T, I} <: AbstractFreeListAllocator{T, I}
    store::Vector{T}
    last::I
    freelist::FreeList{I}
    StaticFreeListAllocator{T, I}(n) where {T, I} =
        new{T, I}(Vector{T}(undef, n), 0, FreeList{I}(n))
    StaticFreeListAllocator{T, I}(store, last, freelist) where {T, I} =
        new{T, I}(store, last, freelist)
end

function allocate!(alloc::StaticFreeListAllocator{T, I}, t::T) where {T, I}
    if !isempty(alloc.freelist)
        i = pop!(alloc.freelist)
        alloc.store[i] = t
        i
    else
        alloc.last += 1
        alloc.store[alloc.last] = t
        alloc.last
    end
end

Base.isempty(alloc::StaticFreeListAllocator{T, I}) where {T, I} =
    alloc.last == alloc.freelist.last

function deallocate!(alloc::StaticFreeListAllocator{T, I}, i::I) where {T, I}
    if i !== alloc.last
        push!(alloc.freelist, i)
    else
        alloc.last -= 1
    end
end

Base.getindex(alloc::StaticFreeListAllocator{T}, i::I) where {T, I} =
    alloc.store[i]
Base.setindex!(alloc::StaticFreeListAllocator{T, I}, t::T, i::I)  where {T, I} =
    alloc.store[i] = t

function Base.empty!(alloc::StaticFreeListAllocator{T, I}) where {T, I}
    alloc.last = 0
end

const N = 16

mutable struct VariableAllocator{T, I} <: AbstractAllocator{T, I}
    direction::Direction
    n::I
    store::Vector{T}
    first::I
    last::I
    VariableAllocator{T, I}(n, direction::Forward, reserve=0) where {T, I} =
        new{T, I}(direction, n, Vector{T}(undef, n), 1, reserve)
    VariableAllocator{T, I}(n, direction::Backward, reserve=0) where {T, I} =
        new{T, I}(direction, n, Vector{T}(undef, n), n + 1 - reserve, n)
    VariableAllocator{T, I}(n, store, first, last, reserve=0) where {T, I} =
        new{T, I}(direction, n, store, first, last)
end
VariableAllocator{T, I}(n::I=N) where {T, I} = VariableAllocator{T, I}(n, Forward())

Base.size(alloc::VariableAllocator{T, I}) where {T, I} =
    (alloc.last - alloc.first + 1,)
Base.similar(alloc::VariableAllocator{T, I}, ::Type{T}, dims::Tuple{I}) where {T, I} =
    VariableAllocator{T, I}(dims[1], alloc.direction, dims[1])
# Base.copy(alloc::VariableAllocator{T, I}) where {T, I} =
#    VariableAllocator{T, A}(alloc.n, copy(alloc.store), alloc.first, alloc.last)

@noinline function resizeend!(alloc::VariableAllocator{T, I}, n) where {T, I}
    if n > alloc.n
        Base._growend!(alloc.store, n - alloc.n)
    elseif n < alloc.n
        Base._deleteend!(alloc.store, alloc.n - n)
    end
    alloc.n = n
end
@noinline function resizebegin!(alloc::VariableAllocator{T, I}, n) where {T, I}
    if n > alloc.n
        Base._growbeg!(alloc.store, n - alloc.n)
    elseif n < alloc.n
        Base._deletebeg!(alloc.store, alloc.n - n)
    end
    alloc.first += n - alloc.n
    alloc.last += n - alloc.n
    alloc.n = n
end

function pushend!(alloc::VariableAllocator{T, I}, t::T) where {T, I}
    if alloc.last >= alloc.n
        resizeend!(alloc, 2 * alloc.n)
    end
    alloc.last += 1
    alloc.store[alloc.last] = t
    alloc.last
end
function pushbegin!(alloc::VariableAllocator{T, I}, t::T) where {T, I}
    if alloc.first <= 1
        resizebegin!(alloc, 2 * alloc.n)
    end
    alloc.first -= 1
    alloc.store[alloc.first] = t
    alloc.first
end

Base.isempty(alloc::VariableAllocator{T, I}) where {T, I} =
    alloc.first == alloc.last + 1

function popend!(alloc::VariableAllocator{T, I}) where {T, I}
    t = alloc.store[alloc.last]
    alloc.last -= 1
    if max(N, 4 * alloc.last) < alloc.n
        resizeend!(alloc, alloc.n ÷ 2)
    end
    t
end
function popbegin!(alloc::VariableAllocator{T, I}) where {T, I}
    t = alloc.store[alloc.first]
    alloc.first += 1
    if max(N, 4 * (alloc.n - alloc.first)) < alloc.n
        resizebegin!(alloc, alloc.n ÷ 2)
    end
    t
end

Base.getindex(alloc::VariableAllocator{T, I}, i::I) where {T, I} =
    alloc.store[i]
Base.setindex!(alloc::VariableAllocator{T, I}, t::T, i::I)  where {T, I} =
    alloc.store[i] = t

function emptyend!(alloc::VariableAllocator{T, I}) where {T, I}
    resizeend!(alloc, N)
    alloc.first = 1
    alloc.last = 0
end
function emptybegin!(alloc::VariableAllocator{T, I}) where {T, I}
    resizebegin!(alloc, N)
    alloc.first = alloc.n + 1
    alloc.last = alloc.n
end
