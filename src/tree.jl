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

nil(alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}} = 0
node(t::T, left::I, right::I, height::I, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}} =
    pushend!(alloc, (t, left, right, height))

height(tree::Nothing) = 0
height(tree::Node{T}) where T = tree.height

height!(tree::Nothing) = 0
function height!(tree::Node{T}) where T
    #= left = height(tree.left)
    right = height(tree.right)
    max(left, right) + 1  =#
    left = height(tree.left)
    right = height(tree.right)
    max(left, right) + 1
end

function height(tree::I, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        0
    else
        _, _, _, height = alloc[tree]
        height
    end
end

function height!(tree::I, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        0
    else
        value, left, right, _ = alloc[tree]
        @assert left != tree && right != tree
        height_left = height(left, alloc)
        height_right = height(right, alloc)
        max(height_left, height_right) + 1
    end
end

function rotateright(tree::Node{T}) where T
    tree.left.right, tree.left, tree =
        tree, tree.left.right, tree.left
    tree.right.height = height!(tree.right)
    tree
end
function rotateleft(tree::Node{T})  where T
    tree.right.left, tree.right, tree =
        tree, tree.right.left, tree.right
    tree.left.height = height!(tree.left)
    tree
end

function rotateright(tree::I, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}}
    value, left, right, _ = alloc[tree]
    @assert left != tree && right != tree
    _, _, left_right, _ = alloc[left]
    alloc[left] = Base.setindex(alloc[left], tree, 3)
    right = tree
    alloc[tree] = Base.setindex(alloc[tree], left_right, 2)
    tree = left
    alloc[right] = Base.setindex(alloc[right], height!(right, alloc), 4)
    tree
end
function rotateleft(tree::I, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}}
    value, left, right, _ = alloc[tree]
    @assert left != tree && right != tree
    _, right_left, _, _ = alloc[right]
    alloc[right] = Base.setindex(alloc[right], tree, 2)
    left = tree
    alloc[tree] = Base.setindex(alloc[tree], right_left, 3)
    tree = right
    alloc[left] = Base.setindex(alloc[left], height!(left, alloc), 4)
    tree
end

balance(tree::Nothing) = nothing
function balance(tree::Node{T}) where T
    height_left = height(tree.left)
    height_right = height(tree.right)
    if height_left < height_right - 1
        tree = rotateleft(tree)
        height_left = tree.left.height
    elseif height_left > height_right + 1
        tree = rotateright(tree)
        height_right = tree.right.height
    end
    # _height = height!(tree)
    _height = max(height_left, height_right) + 1
    if tree.height != _height
        tree.height = _height
    end
    tree
end

function balance(tree::I, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}}
    _, left, right, in_height = alloc[tree]
    @assert left != tree && right != tree
    height_left = height(left, alloc)
    height_right = height(right, alloc)
    if height_left < height_right - 1
        tree = rotateleft(tree, alloc)
        _, left, _, in_height = alloc[tree]
        _, _, _, height_left = alloc[left]
    elseif height_left > height_right + 1
        tree = rotateright(tree, alloc)
        _, _, right, in_height = alloc[tree]
        _, _, _, height_right = alloc[right]
    end
    out_height = max(height_left, height_right) + 1
    if in_height != out_height
        alloc[tree] = Base.setindex(alloc[tree], out_height, 4)
    end
    tree
end

insert(tree::Nothing, t::T) where T = node(t, nothing, nothing, 1)
function insert(tree::Node{T}, t::T) where T
    if t < tree.value
        tree.left = insert(tree.left, t)
        tree = balance(tree)
    elseif t > tree.value
        tree.right = insert(tree.right, t)
        tree = balance(tree)
    end
    tree
end

function insert(tree::I, t::T, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        node(t, 0, 0, 1, alloc)
    else
        value, left, right, _ = alloc[tree]
        @assert left != tree && right != tree
        if t < value
            left = insert(left, t, alloc)
            alloc[tree] = Base.setindex(alloc[tree], left, 2)
            tree = balance(tree, alloc)
        elseif t > value
            right = insert(right, t, alloc)
            alloc[tree] = Base.setindex(alloc[tree], right, 3)
            tree = balance(tree, alloc)
        end
        tree
    end
end

Base.haskey(tree::Nothing, t::T) where T = false
function Base.haskey(tree::Node{T}, t::T) where T
    if t < tree.value
        haskey(tree.left, t)
    elseif t > tree.value
        haskey(tree.right, t)
    else
        true
    end
end

function Base.haskey(tree::I, t::T, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        false
    else
        value, left, right, _ = alloc[tree]
        @assert left != tree && right != tree
        if t < value
            haskey(left, t, alloc)
        elseif t > value
            haskey(right, t, alloc)
        else
            true
        end
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

delete(tree::Nothing, t::T) where T = tree, tree
function delete(tree::Node{T}, t::T) where T
    if t < tree.value
        tree.left = delete(tree.left, t)
        tree = balance(tree)
    elseif t > tree.value
        tree.right = delete(tree.right, t)
        tree = balance(tree)
    else
        if tree.left == nothing && tree.right == nothing
            tree = nothing
        elseif height(tree.left) >= height(tree.right)
            tree.value = tree.left.value
            tree.left = delete(tree.left, tree.left.value)
            tree = balance(tree)
        else
            tree.value = tree.right.value
            tree.right = delete(tree.right, tree.right.value)
            tree = balance(tree)
        end
    end
    tree
end

function delete(tree::I, t::T, alloc::A) where {T, I, A <: AbstractAllocator{Tuple{T, I, I, I}, I}}
    if tree == 0
        0
    else
        value, left, right, _ = alloc[tree]
        @assert left != tree && right != tree
        if t < value
            left = delete(left, t, alloc)
            alloc[tree] = Base.setindex(alloc[tree], left, 2)
            tree = balance(tree, alloc)
        elseif t > value
            right = delete(right, t, alloc)
            alloc[tree] = Base.setindex(alloc[tree], right, 3)
            tree = balance(tree, alloc)
        else
            if left == 0 && right == 0
                tree = 0
            else
                height_left = height(left, alloc)
                height_right = height(right, alloc)
                if height_left >= height_right
                    value, _, _, _ = alloc[left]
                    alloc[tree] = Base.setindex(alloc[tree], value, 1)
                    left = delete(left, value, alloc)
                    alloc[tree] = Base.setindex(alloc[tree], left, 2)
                    tree = balance(tree, alloc)
                else
                    value, _, _, _ = alloc[right]
                    alloc[tree] = Base.setindex(alloc[tree], value, 1)
                    right = delete(right, value, alloc)
                    alloc[tree] = Base.setindex(alloc[tree], right, 3)
                    tree = balance(tree, alloc)
                end
            end
        end
        tree
    end
end
