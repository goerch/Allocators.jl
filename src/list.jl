const ListNode{T, I} = Tuple{T, I}

mutable struct Cons{T}
    car::T
    cdr::Union{Nothing, Cons{T}}
end
const List{T} = Union{Nothing, Cons{T}}

nil() = nothing
cons(car::T, cdr::List{T}) where T = Cons{T}(car, cdr)

nil(alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I}, I}} = 0
cons(car::T, cdr::I, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I}, I}} =
    pushend!(alloc, (car, cdr))

nil(alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I}, I}} = 0
cons(car::T, cdr::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I}, I}} =
    allocate!(alloc, (car, cdr))

Base.iterate(::Cons{T}, cdr::Nothing) where T = nothing
Base.iterate(list::Nothing) where T = nothing
Base.iterate(::Cons{T}, cdr::Cons{T}) where T = cdr.car, cdr.cdr
Base.iterate(list::Cons{T}) where T = list.car, list.cdr

struct ListIterator{T, I, A <: AbstractAllocator{Tuple{T, I}, I}}
    list::Tuple{I, A}
end

Base.iterate(iter::ListIterator{T, I, A}, i::I) where {T, I, A <: AbstractAllocator{Tuple{T, I}, I}} =
    i == 0 ? nothing : iter.list[2][i]
Base.iterate(iter::ListIterator{T, I, A}) where {T, I, A <: AbstractAllocator{Tuple{T, I}, I}} =
    iter.list[1] == 0 ? nothing : iter.list[2][iter.list[1]]

deallocate(iter::ListIterator{T, I, A}) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I}, I}} =
    deallocate!(iter.list[2], iter.list[1])
deallocate(alloc::A, i::I) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I}, I}} =
    deallocate!(alloc, i)

@noinline function Base.reverse(list::List{T}) where T
    #= res = nil()
    for t in list
        res = cons(t, res)
    end
    res =#
    first = list
    list_next = iterate(list)
    while list_next !== nothing
        car, cdr = list_next
        list_next = iterate(list, cdr)
        if list_next !== nothing
            cdr.cdr = list
            list = cdr
        else
            first.cdr = cdr
        end
    end
    list
end

@noinline function Base.reverse(iter::ListIterator{T, I, A}) where {T, I, A <: AbstractAllocator{Tuple{T, I}}}
    #= res = nil(iter.list.alloc)
    for t in iter.list
        res = cons(t, res, iter.list.alloc)
    end
    res =#
    first = list = iter.list
    iter_next = iterate(iter)
    while iter_next != nothing
        t, i = iter_next
        iter_next = iterate(iter, i)
        if iter_next != nothing
            # list[2][i] = (list[2][i][1], list[1])
            list[2][i] = Base.setindex(list[2][i], list[1], 2)
            # list = (i, list[2])
            list =  Base.setindex(list, i, 1)
        else
            # list[2][first[1]] = (list[2][first[1]][1], i)
            list[2][first[1]] =  Base.setindex(list[2][first[1]], i, 2)
        end
    end
    ListIterator{T, I, A}(list)
end
