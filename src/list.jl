const ListNode{T, I} = Tuple{T, I}

struct Cons{T}
    car::T
    cdr::Union{Nothing, Cons{T}}
end
const List{T} = Union{Nothing, Cons{T}}

nil() = nothing
cons(car::T, cdr::List{T}) where T = Cons{T}(car, cdr)

nil(alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I}, I}} = 0
cons(car::T, cdr::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I}, I}} =
    allocateend!(alloc, (car, cdr))

deallocate(i::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I}, I}} =
    deallocate!(alloc, i)
