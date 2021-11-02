const ListNode{T, I} = Tuple{T, I}

struct Cons{T}
    car::T
    cdr::Union{Nothing, Cons{T}}
end
const List{T} = Union{Nothing, Cons{T}}

@inline nil() = nothing
@inline cons(car::T, cdr) where T = Cons{T}(car, cdr)

@inline nil(alloc::A) where {T, I, A <: AbstractFreeListAllocator{ListNode{T, I}, I}} = 0
@inline cons(car::T, cdr, alloc::A) where {T, I, A <: AbstractFreeListAllocator{ListNode{T, I}, I}} =
    allocateend!(alloc, (car, cdr))

@inline deallocate(i::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{ListNode{T, I}, I}} =
    deallocate!(alloc, i)
