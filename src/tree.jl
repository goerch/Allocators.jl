const TreeNode{T, I} = Tuple{T, I, I, I}

mutable struct Node{T}
    value::T
    left::Union{Nothing, Node{T}}
    right::Union{Nothing, Node{T}}
    height::Int
end
const Tree{T} = Union{Nothing, Node{T}}

nil() = nothing
node(t::T, left, right, height) where T = Node{T}(t, left, right, height)

nil(alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}} = 0
node(t::T, left::I, right::I, height::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}} =
    allocateend!(alloc, (t, left, right, height))

deallocate(i::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}} =
    deallocate!(alloc, i)

invariantvalue(tree::Nothing) = true
function invariantvalue(tree::Node{T}) where T
    invariant = (tree.left == nothing || tree.left.value < tree.value) &&
                (tree.right == nothing || tree.right.value > tree.value)
    @assert invariant
    invariant
end

function invariantvalue(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        return true
    else
        value, left, right, _ = alloc[tree]
        value_left = nothing
        if left != 0
            value_left, _, _, _ = alloc[left]
        end
        value_right = nothing
        if right != 0
            value_right, _, _, _ = alloc[right]
        end
        invariant = (left == 0 || value_left < value) &&
                    (right == 0 || value_right > value)
        @assert invariant
        invariant
    end
end

height(tree::Nothing) = 0
height(tree::Node{T}) where T = tree.height

height!(tree::Nothing) = 0
function height!(tree::Node{T}) where T
    height_left = height(tree.left)
    height_right = height(tree.right)
    tree.height = max(height_left, height_right) + 1
end

function height(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        0
    else
        _, _, _, height = alloc[tree]
        height
    end
end

function height!(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        0
    else
        _, left, right, _ = alloc[tree]
        height_left = height(left, alloc)
        height_right = height(right, alloc)
        setindex!(alloc, tree, max(height_left, height_right) + 1, 4)
    end
end

function rotateright(tree::Node{T}) where T
    tree.left.right, tree.left, tree =
        tree, tree.left.right, tree.left
    # invariantvalue(tree.left.right)
    # invariantvalue(tree.left)
    # invariantvalue(tree)
    height!(tree.right)
    height!(tree)
    tree
end
function rotateleft(tree::Node{T})  where T
    tree.right.left, tree.right, tree =
        tree, tree.right.left, tree.right
    # invariantvalue(tree.right.left)
    # invariantvalue(tree.right)
    # invariantvalue(tree)
    height!(tree.left)
    height!(tree)
    tree
end

function rotateright(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    value, left, right, _ = alloc[tree]
    _, _, left_right, _ = alloc[left]
    setindex!(alloc, left, tree, 3)
    right = tree
    setindex!(alloc, tree, left_right, 2)
    tree = left
    # invariantvalue(tree, alloc)
    # invariantvalue(left, alloc)
    # invariantvalue(left_right, alloc)
    height!(right, alloc)
    height!(tree, alloc)
    tree
end
function rotateleft(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    value, left, right, _ = alloc[tree]
    _, right_left, _, _ = alloc[right]
    setindex!(alloc, right, tree, 2)
    left = tree
    setindex!(alloc, tree, right_left, 3)
    tree = right
    # invariantvalue(tree, alloc)
    # invariantvalue(right, alloc)
    # invariantvalue(right_left, alloc)
    height!(left, alloc)
    height!(tree, alloc)
    tree
end

balance(tree::Nothing) = nothing
function balance(tree::Node{T}) where T
    height_left = height(tree.left)
    height_right = height(tree.right)
    if height_left < height_right - 1
        tree = rotateleft(tree)
    elseif height_left > height_right + 1
        tree = rotateright(tree)
    else
        height!(tree)
    end
    tree
end

function balance(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    _, left, right, in_height = alloc[tree]
    height_left = height(left, alloc)
    height_right = height(right, alloc)
    if height_left < height_right - 1
        tree = rotateleft(tree, alloc)
    elseif height_left > height_right + 1
        tree = rotateright(tree, alloc)
    else
        height!(tree, alloc)
    end
    tree
end

const StackNode{T, I} = Tuple{Ref{Node{T}}, I, Symbol}

insert(tree::Nothing, t::T) where T = node(t, nothing, nothing, 1)
function insert(tree::Node{T}, t::T) where T
    if t < tree.value
        _height = height(tree.left)
        tree.left = insert(tree.left, t)
        # invariantvalue(tree.left)
        if height(tree.left) != _height
            tree = balance(tree)
            # invariantvalue(tree)
        end
    elseif t > tree.value
        _height = height(tree.right)
        tree.right = insert(tree.right, t)
        # invariantvalue(tree.right)
        if height(tree.right) != _height
            tree = balance(tree)
            # invariantvalue(tree)
        end
    end
    tree
end

function insert(tree::I, t::T, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        node(t, 0, 0, 1, alloc)
    else
        value, left, right, _ = alloc[tree]
        if t < value
            _height = height(left, alloc)
            left = insert(left, t, alloc)
            setindex!(alloc, tree, left, 2)
            # invariantvalue(left, alloc)
            if height(left, alloc) != _height
                tree = balance(tree, alloc)
                # invariantvalue(tree, alloc)
            end
        elseif t > value
            _height = height(right, alloc)
            right = insert(right, t, alloc)
            setindex!(alloc, tree, right, 3)
            # invariantvalue(right, alloc)
            if height(right, alloc) != _height
                tree = balance(tree, alloc)
                # invariantvalue(tree, alloc)
            end
        end
        tree
    end
end

Base.haskey(tree::Nothing, t::T) where T = false
function Base.haskey(tree::Node{T}, t::T) where T
    #= if t < tree.value
        haskey(tree.left, t)
    elseif t > tree.value
        haskey(tree.right, t)
    else
        true
    end =#
    while tree != nothing
        if t < tree.value
            tree = tree.left
        elseif t > tree.value
            tree = tree.right
        else
            return true
        end
    end
    return false
end

function Base.haskey(tree::I, t::T, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    #= if tree == 0
        false
    else
        value, left, right, _ = alloc[tree]
        if t < value
            haskey(left, t, alloc)
        elseif t > value
            haskey(right, t, alloc)
        else
            true
        end
    end =#
    while tree != 0
        value, left, right, _ = alloc[tree]
        if t < value
            tree = left
        elseif t > value
            tree = right
        else
            return true
        end
    end
    return false
end

function getleftmost(tree::Node{T}) where T
    #= if tree.left == nothing
        tree.value
    else
        getleftmost(tree.left)
    end =#
    while tree.left != nothing
        tree = tree.left
    end
    tree.value
end

function getrightmost(tree::Tree{T}) where T
    #= if tree.right == nothing
        tree.value
    else
        getrightmost(tree.right)
    end =#
    while tree.right != nothing
        tree = tree.right
    end
    tree.value
end

delete(tree::Nothing, t::T) where T = tree
function delete(tree::Node{T}, t::T) where T
    if t < tree.value
        _height = height(tree.left)
        tree.left = delete(tree.left, t)
        # invariantvalue(tree.left)
        if height(tree.left) != _height
            tree = balance(tree)
            # invariantvalue(tree)
        end
    elseif t > tree.value
        _height = height(tree.right)
        tree.right = delete(tree.right, t)
        # invariantvalue(tree.right)
        if height(tree.right) != _height
            tree = balance(tree)
            # invariantvalue(tree)
        end
    else
        if tree.left == nothing && tree.right == nothing
            tree = nothing
        else
            height_left = height(tree.left)
            height_right = height(tree.right)
            if height_left >= height_right
                tree.value = getrightmost(tree.left)
                tree.left = delete(tree.left, tree.value)
                # invariantvalue(tree.left)
                if height(tree.left) != height_left
                    tree = balance(tree)
                    # invariantvalue(tree)
                end
            else
                tree.value = getleftmost(tree.right)
                tree.right = delete(tree.right, tree.value)
                # invariantvalue(tree.right)
                if height(tree.right) != height_right
                    tree = balance(tree)
                    # invariantvalue(tree)
                end
            end
        end
    end
    tree
end

function getleftmost(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    value, left, _, _ = alloc[tree]
    if left == 0
        value
    else
        getleftmost(left, alloc)
    end
    #= while tree != 0
        value, left, right, _ = alloc[tree]
        if t < value
            tree = left
        elseif t > value
            tree = right
        else
            return true
        end
    end
    return false =#
end

function getrightmost(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    value, _, right, _ = alloc[tree]
    if right == 0
        value
    else
        getrightmost(right, alloc)
    end
end

function delete(tree::I, t::T, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        0
    else
        value, left, right, _ = alloc[tree]
        if t < value
            _height = height(left, alloc)
            left = delete(left, t, alloc)
            setindex!(alloc, tree, left, 2)
            # invariantvalue(left, alloc)
            if height(left, alloc) != _height
                tree = balance(tree, alloc)
                # invariantvalue(tree, alloc)
            end
        elseif t > value
            _height = height(right, alloc)
            right = delete(right, t, alloc)
            setindex!(alloc, tree, right, 3)
            # invariantvalue(right, alloc)
            if height(right, alloc) != _height
                tree = balance(tree, alloc)
                # invariantvalue(tree, alloc)
            end
        else
            if left == 0 && right == 0
                deallocate(tree, alloc)
                tree = 0
            else
                height_left = height(left, alloc)
                height_right = height(right, alloc)
                if height_left >= height_right
                    value = getrightmost(left, alloc)
                    setindex!(alloc, tree, value, 1)
                    left = delete(left, value, alloc)
                    setindex!(alloc, tree, left, 2)
                    # invariantvalue(left, alloc)
                    if height(left, alloc) != height_left
                        tree = balance(tree, alloc)
                        # invariantvalue(tree, alloc)
                    end
                else
                    value = getleftmost(right, alloc)
                    setindex!(alloc, tree, value, 1)
                    right = delete(right, value, alloc)
                    setindex!(alloc, tree, right, 3)
                    # invariantvalue(right, alloc)
                    if height(right, alloc) != height_right
                        tree = balance(tree, alloc)
                        # invariantvalue(tree, alloc)
                    end
                end
            end
        end
        tree
    end
end
