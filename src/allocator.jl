using StructArrays

abstract type AbstractFreeListAllocator{T, I} end
abstract type AbstractAllocator{T, I} <: AbstractFreeListAllocator{T, I} end

const N = 16

# Allocator
mutable struct Allocator{T, I} <: AbstractAllocator{T, I}
    n::I
    resizable::Bool
    store::Vector{T}
    first::I
    last::I
    Allocator{T, I}(::Nothing, init=0) where {T, I} =
        new{T, I}(N, true, Vector{T}(undef, N), init + 1, init)
    Allocator{T, I}(n::I, init=0) where {T, I} =
        new{T, I}(n, false, Vector{T}(undef, n), init + 1, init)
end

Base.getindex(alloc::Allocator{T, I}, i::I) where {T, I} =
    @inbounds alloc.store[i]
Base.setindex!(alloc::Allocator{T, I}, t::T, i::I)  where {T, I} =
    @inbounds alloc.store[i] = t

@noinline function resizeend!(alloc::Allocator{T, I}, n) where {T, I}
    if n > alloc.n
        Base._growend!(alloc.store, n - alloc.n)
    elseif n < alloc.n
        Base._deleteend!(alloc.store, alloc.n - n)
    end
    alloc.n = n
end
@noinline function resizebegin!(alloc::Allocator{T, I}, n) where {T, I}
    if n > alloc.n
        Base._growbeg!(alloc.store, n - alloc.n)
    elseif n < alloc.n
        Base._deletebeg!(alloc.store, alloc.n - n)
    end
    alloc.first += n - alloc.n
    alloc.last += n - alloc.n
    alloc.n = n
end

function allocateend!(alloc::Allocator{T, I}, t::T) where {T, I}
    if alloc.resizable && alloc.last >= alloc.n
        resizeend!(alloc, 2 * alloc.n)
    end
    alloc.last += 1
    @inbounds alloc.store[alloc.last] = t
    alloc.last
end
function allocatebegin!(alloc::Allocator{T, I}, t::T) where {T, I}
    if alloc.resizable && alloc.first <= 1
        resizebegin!(alloc, 2 * alloc.n)
    end
    alloc.first -= 1
    @inbounds alloc.store[alloc.first] = t
    alloc.first
end
function deallocateend!(alloc::Allocator{T, I}) where {T, I}
    alloc.last -= 1
    if alloc.resizable && max(N, 4 * alloc.last) < alloc.n
        resizeend!(alloc, alloc.n ÷ 2)
    end
end
function deallocatebegin!(alloc::Allocator{T, I}) where {T, I}
    alloc.first += 1
    if alloc.resizable && max(N, 4 * (alloc.n - alloc.first)) < alloc.n
        resizebegin!(alloc, alloc.n ÷ 2)
    end
end
function deallocate!(alloc::Allocator{T, I}, i::I) where {T, I}
    # nope
end

Base.isempty(alloc::Allocator{T, I}) where {T, I} =
    alloc.first == alloc.last + 1
function emptyend!(alloc::Allocator{T, I}) where {T, I}
    alloc.first = 1
    alloc.last = 0
end
function emptybegin!(alloc::Allocator{T, I}) where {T, I}
    alloc.first = alloc.n + 1
    alloc.last = alloc.n
end


# FreeListAllocator
struct FreeListAllocator{T, I} <: AbstractFreeListAllocator{T, I}
    used::Allocator{T, I}
    free::Allocator{I, I}
    FreeListAllocator{T, I}(::Nothing, init=0) where {T, I} =
        new{T, I}(Allocator{T, I}(nothing, init), Allocator{I, I}(nothing, 0))
    FreeListAllocator{T, I}(n::I, init=0) where {T, I} =
        new{T, I}(Allocator{T, I}(n, init), Allocator{I, I}(n, 0))
end

Base.getindex(alloc::FreeListAllocator{T}, i::I) where {T, I} =
    alloc.used[i]
Base.setindex!(alloc::FreeListAllocator{T, I}, t::T, i::I)  where {T, I} =
    alloc.used[i] = t

function allocateend!(alloc::FreeListAllocator{T, I}, t::T) where {T, I}
    if isempty(alloc.free)
        allocateend!(alloc.used, t)
    else
        # deallocateend!(alloc.free)
        i = alloc.free[alloc.free.last]
        alloc.free.last -= 1
        alloc.used[i] = t
        i
    end
end
function allocatebegin!(alloc::FreeListAllocator{T, I}, t::T) where {T, I}
    if isempty(alloc.free)
        allocatebegin!(alloc.used, t)
    else
        # deallocateend!(alloc.free)
        i = alloc.free[alloc.free.last]
        alloc.free.last -= 1
        alloc.used[i] = t
        i
    end
end
#= function deallocateend!(alloc::FreeListAllocator{T, I}) where {T, I}
    deallocateend!(alloc.used)
end
function deallocatebegin!(alloc::FreeListAllocator{T, I}) where {T, I}
    deallocatebegin!(alloc.used)
end =#
function deallocate!(alloc::FreeListAllocator{T, I}, i::I) where {T, I}
    allocateend!(alloc.free, i)
end

function Base.isempty(alloc::FreeListAllocator{T, I}) where {T, I}
    alloc.free.last + 1 - alloc.free.first == alloc.used.last + 1 - alloc.used.first
end

function emptyend!(alloc::FreeListAllocator{T, I}) where {T, I}
    emptyend!(alloc.used)
    emptyend!(alloc.free)
end
function emptybegin!(alloc::FreeListAllocator{T, I}) where {T, I}
    emptybegin!(alloc.used)
    emptyend!(alloc.free)
end


# SOAllocator
mutable struct SOAllocator{T, I, S <: StructVector{T}} <: AbstractAllocator{T, I}
    n::I
    resizable::Bool
    store::S
    first::I
    last::I
    SOAllocator{T, I, S}(store::S, ::Nothing, init=0) where {T, I, S <: StructVector{T}} =
        new{T, I, S}(N, true, store, init + 1, init)
    SOAllocator{T, I, S}(store::S, n::I, init=0) where {T, I, S <: StructVector{T}} =
        new{T, I, S}(n, false, store, init + 1, init)
end

Base.getindex(alloc::SOAllocator{T, I, S}, i::I) where {T, I, S} =
    @inbounds alloc.store[i]
Base.setindex!(alloc::SOAllocator{T, I, S}, t::T, i::I)  where {T, I, S} =
    @inbounds alloc.store[i] = t

@noinline function resizeend!(alloc::SOAllocator{T, I, S}, n) where {T, I, S}
    if n > alloc.n
        Base._growend!(alloc.store, n - alloc.n)
    elseif n < alloc.n
        Base._deleteend!(alloc.store, alloc.n - n)
    end
    alloc.n = n
end
@noinline function resizebegin!(alloc::SOAllocator{T, I, S}, n) where {T, I, S}
    if n > alloc.n
        Base._growbeg!(alloc.store, n - alloc.n)
    elseif n < alloc.n
        Base._deletebeg!(alloc.store, alloc.n - n)
    end
    alloc.first += n - alloc.n
    alloc.last += n - alloc.n
    alloc.n = n
end

function allocateend!(alloc::SOAllocator{T, I, S}, t::T) where {T, I, S}
    if alloc.resizable && alloc.last >= alloc.n
        resizeend!(alloc, 2 * alloc.n)
    end
    alloc.last += 1
    @inbounds alloc.store[alloc.last] = t
    alloc.last
end
function allocatebegin!(alloc::SOAllocator{T, I, S}, t::T) where {T, I, S}
    if alloc.resizable && alloc.first <= 1
        resizebegin!(alloc, 2 * alloc.n)
    end
    alloc.first -= 1
    @inbounds alloc.store[alloc.first] = t
    alloc.first
end
function deallocateend!(alloc::SOAllocator{T, I, S}) where {T, I, S}
    alloc.last -= 1
    if alloc.resizable && max(N, 4 * alloc.last) < alloc.n
        resizeend!(alloc, alloc.n ÷ 2)
    end
end
function deallocatebegin!(alloc::SOAllocator{T, I, S}) where {T, I, S}
    alloc.first += 1
    if alloc.resizable && max(N, 4 * (alloc.n - alloc.first)) < alloc.n
        resizebegin!(alloc, alloc.n ÷ 2)
    end
end
function deallocate!(alloc::SOAllocator{T, I, S}, i::I) where {T, I, S}
    # nope
end

Base.isempty(alloc::SOAllocator{T, I, S}) where {T, I, S} =
    alloc.first == alloc.last + 1
function emptyend!(alloc::SOAllocator{T, I, S}) where {T, I, S}
    alloc.first = 1
    alloc.last = 0
end
function emptybegin!(alloc::SOAllocator{T, I, S}) where {T, I, S}
    alloc.first = alloc.n + 1
    alloc.last = alloc.n
end
