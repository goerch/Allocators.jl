const TreeNode{T, I} = Tuple{T, I, I, I, I}

mutable struct Node{T}
    value::T
    left::Union{Nothing, Node{T}}
    right::Union{Nothing, Node{T}}
    parent::Union{Nothing, Node{T}}
    height::Int
end
const Tree{T} = Union{Nothing, Node{T}}

nil() = nothing
node(t::T, left, right, parent, height) where T = Node{T}(t, left, right, parent, height)

nil(alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}} = 0
node(t::T, left::I, right::I, parent::I, height::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}} =
    allocateend!(alloc, (t, left, right, parent, height))

deallocate(i::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}} =
    deallocate!(alloc, i)

value(tree::Nothing) = @assert false
function value(tree::Node{T}) where T
    tree.value
end

left(tree::Nothing) = @assert false
function left(tree::Node{T}) where T
    tree.left
end

right(tree::Nothing) = @assert false
function right(tree::Node{T}) where T
    tree.right
end

Base.parent(tree::Nothing) = @assert false
function Base.parent(tree::Node{T}) where T
    tree.parent
end

height(tree::Nothing) = 0
height(tree::Node{T}) where T = tree.height

value!(tree::Nothing, left::Tree{T}) where T = @assert false
function value!(tree::Node{T}, value::T) where T
    tree.value = value
end

left!(tree::Nothing, left::Tree{T}) where T = @assert false
function left!(tree::Node{T}, left::Tree{T}) where T
    tree.left = left
end

right!(tree::Nothing, right::Tree{T}) where T = @assert false
function right!(tree::Node{T}, right::Tree{T}) where T
    tree.right = right
end

parent!(tree::Nothing, parent::Tree{T}) where T = @assert false
function parent!(tree::Node{T}, parent::Tree{T}) where T
    tree.parent = parent
end

height!(tree::Nothing) = @assert false
function height!(tree::Node{T}) where T
    height_left = height(tree.left)
    height_right = height(tree.right)
    tree.height = max(height_left, height_right) + 1
end

function value(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    tree === 0 ? (@assert false) : alloc[tree][1]
end

function left(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    tree === 0 ? (@assert false) : alloc[tree][2]
end

function right(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    tree === 0 ? (@assert false) : alloc[tree][3]
end

function Base.parent(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    tree === 0 ? (@assert false) : alloc[tree][4]
end

function height(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    tree === 0 ? 0 : alloc[tree][5]
end

function value!(tree::I, value::T, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    if tree !== 0
        setindex!(alloc, tree, value, 1)
    else
        @assert false
    end
end

function left!(tree::I, left::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    if tree !== 0
        setindex!(alloc, tree, left, 2)
    else
        @assert false
    end
end

function right!(tree::I, right::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    if tree !== 0
        setindex!(alloc, tree, right, 3)
    else
        @assert false
    end
end

function parent!(tree::I, parent::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    if tree !== 0
        setindex!(alloc, tree, parent, 4)
    else
        @assert false
    end
end

function height!(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    if tree !== 0
        _left = left(tree, alloc)
        _right = right(tree, alloc)
        height_left = height(_left, alloc)
        height_right = height(_right, alloc)
        setindex!(alloc, tree, max(height_left, height_right) + 1, 5)
    else
        @assert false
    end
end

function rotateright(tree::Node{T}) where T
    _left = left(tree)
    _parent = parent(tree)
    left_right = right(_left)
    right!(_left, tree)
    parent!(tree, _left)
    left!(tree, left_right)
    if left_right !== nothing
        parent!(left_right, tree)
    end
    height!(tree)
    parent!(_left, _parent)
    height!(_left)
    _left
end
function rotateleft(tree::Node{T})  where T
    _right = right(tree)
    _parent = parent(tree)
    right_left = left(_right)
    left!(_right, tree)
    parent!(tree, _right)
    right!(tree, right_left)
    if right_left !== nothing
        parent!(right_left, tree)
    end
    height!(tree)
    parent!(_right, _parent)
    height!(_right)
    _right
end

function rotateright(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    _left = left(tree, alloc)
    _parent = parent(tree, alloc)
    left_right = right(_left, alloc)
    right!(_left, tree, alloc)
    parent!(tree, _left, alloc)
    left!(tree, left_right, alloc)
    if left_right !== 0
        parent!(left_right, tree, alloc)
    end
    height!(tree, alloc)
    parent!(_left, _parent, alloc)
    height!(_left, alloc)
    _left
end
function rotateleft(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    _right = right(tree, alloc)
    _parent = parent(tree, alloc)
    right_left = left(_right, alloc)
    left!(_right, tree, alloc)
    parent!(tree, _right, alloc)
    right!(tree, right_left, alloc)
    if right_left !== 0
        parent!(right_left, tree, alloc)
    end
    height!(tree, alloc)
    parent!(_right, _parent, alloc)
    height!(_right, alloc)
    _right
end

balance(tree::Nothing) = nothing
function balance(tree::Node{T}) where T
    _left = left(tree)
    _right = right(tree)
    height_left = height(_left)
    height_right = height(_right)
    if height_left < height_right - 1
        right_left = left(_right)
        right_right = right(_right)
        height_right_left = height(right_left)
        height_right_right = height(right_right)
        if height_right_left > height_right_right
            _right = rotateright(_right)
            right!(tree, _right)
        end
        tree = rotateleft(tree)
    elseif height_left > height_right + 1
        left_left = left(_left)
        left_right = right(_left)
        height_left_left = height(left_left)
        height_left_right = height(left_right)
        if height_left_left < height_left_right
            _left = rotateleft(_left)
            left!(tree, _left)
        end
        tree = rotateright(tree)
    else
        height!(tree)
    end
    tree
end

function balance(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    _left = left(tree, alloc)
    _right = right(tree, alloc)
    height_left = height(_left, alloc)
    height_right = height(_right, alloc)
    if height_left < height_right - 1
        right_left = left(_right, alloc)
        right_right = right(_right, alloc)
        height_right_left = height(right_left, alloc)
        height_right_right = height(right_right, alloc)
        if height_right_left > height_right_right
            _right = rotateright(_right, alloc)
            right!(tree, _right, alloc)
        end
        tree = rotateleft(tree, alloc)
    elseif height_left > height_right + 1
        left_left = left(_left, alloc)
        left_right = right(_left, alloc)
        height_left_left = height(left_left, alloc)
        height_left_right = height(left_right, alloc)
        if height_left_left < height_left_right
            _left = rotateleft(_left, alloc)
            left!(tree, _left, alloc)
        end
        tree = rotateright(tree, alloc)
    else
        height!(tree, alloc)
    end
    tree
end

function insert(tree::Tree{T}, t::T) where T
    _parent = nothing
    while tree !== nothing
        _value = value(tree)
        if t < _value
            _parent = tree
            tree = left(tree)
        elseif t > _value
            _parent = tree
            tree = right(tree)
        else
            break
        end
    end
    _balance = false
    _update = false
    if tree === nothing
        _balance = true
        _update = true
        tree = node(t, nothing, nothing, _parent, 1)
    end
    while _parent !== nothing
        if _update
            _value = value(_parent)
            if t < _value
                left!(_parent, tree)
            elseif t > _value
                right!(_parent, tree)
            end
            if _balance
                _height = height(_parent)
                _parent = balance(_parent)
                _balance = height(_parent) !== _height
            else
                _update = false
            end
        end
        tree = _parent
        _parent = parent(tree)
    end
    tree
end

function insert(tree::I, t::T, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    _parent = 0
    while tree !== 0
        _value = value(tree, alloc)
        if t < _value
            _parent = tree
            tree = left(tree, alloc)
        elseif t > _value
            _parent = tree
            tree = right(tree, alloc)
        else
            break
        end
    end
    _balance = false
    _update = false
    if tree === 0
        _balance = true
        _update = true
        tree = node(t, 0, 0, _parent, 1, alloc)
    end
    while _parent !== 0
        if _update
            _value = value(_parent, alloc)
            if t < _value
                left!(_parent, tree, alloc)
            elseif t > _value
                right!(_parent, tree, alloc)
            end
            if _balance
                _height = height(_parent, alloc)
                _parent = balance(_parent, alloc)
                _balance = height(_parent, alloc) !== _height
            else
                _update = false
            end
        end
        tree = _parent
        _parent = parent(tree, alloc)
    end
    tree
end

Base.haskey(tree::Nothing, t::T) where T = false
function Base.haskey(tree::Node{T}, t::T) where T
    while tree !== nothing
        _value = value(tree)
        if t < _value
            tree = left(tree)
        elseif t > _value
            tree = right(tree)
        else
            return true
        end
    end
    return false
end

function Base.haskey(tree::I, t::T, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    while tree !== 0
        _value = value(tree, alloc)
        if t < _value
            tree = left(tree, alloc)
        elseif t > _value
            tree = right(tree, alloc)
        else
            return true
        end
    end
    return false
end

function getleftmost(tree::Node{T}) where T
    _left = left(tree)
    while _left !== nothing
        tree = _left
        _left = left(tree)
    end
    value(tree)
end

function getrightmost(tree::Tree{T}) where T
    _right = right(tree)
    while _right !== nothing
        tree = _right
        _right = right(tree)
    end
    value(tree)
end

function getleftmost(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    _left = left(tree, alloc)
    while _left !== 0
        tree = _left
        _left = left(tree, alloc)
    end
    value(tree, alloc)
end

function getrightmost(tree::I, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    _right = right(tree, alloc)
    while _right !== 0
        tree = _right
        _right = right(tree, alloc)
    end
    value(tree, alloc)
end


function delete(tree::Tree{T}, t::T) where T
    _parent = nothing
    while tree !== nothing
        _value = value(tree)
        if t < _value
            _parent = tree
            tree = left(tree)
        elseif t > _value
            _parent = tree
            tree = right(tree)
        else
            break
        end
    end
    _balance = false
    _update = false
    if tree !== nothing
        _balance = true
        _update = true
        _left = left(tree)
        _right = right(tree)
        if _left === nothing && _right === nothing
            tree = nothing
        elseif _left === nothing
            value!(tree, value(_right))
            left!(tree, left(_right))
            right!(tree, right(_right))
            height!(tree)
        elseif _right === nothing
            value!(tree, value(_left))
            left!(tree, left(_left))
            right!(tree, right(_left))
            height!(tree)
        else
            height_left = height(_left)
            height_right = height(_right)
            if height_left >= height_right
                _value = getrightmost(_left)
                value!(tree, _value)
                parent!(_left, nothing)
                _left = delete(_left, _value)
                if _left !== nothing
                    parent!(_left, tree)
                end
                left!(tree, _left)
                height!(tree)
                _height = height(tree)
                tree = balance(tree)
                _balance = height(tree) !== _height
            else
                _value = getleftmost(_right)
                value!(tree, _value)
                parent!(_right, nothing)
                _right = delete(_right, _value)
                if right !== nothing
                    parent!(_right, tree)
                end
                right!(tree, _right)
                height!(tree)
                _height = height(tree)
                tree = balance(tree)
                _balance = height(tree) !== _height
            end
        end
    end
    while _parent !== nothing
        if _update
            _value = value(_parent)
            if t < _value
                left!(_parent, tree)
            elseif t > _value
                right!(_parent, tree)
            end
            if _balance
                _height = height(_parent)
                _parent = balance(_parent)
                _balance = height(_parent) !== _height
            else
                _update = false
            end
        end
        tree = _parent
        _parent = parent(tree)
    end
    tree
end

function delete(tree::I, t::T, alloc::A) where {T, I, A <: AbstractFreeListAllocator{Tuple{T, I, I, I, I}, I}}
    _parent = 0
    while tree !== 0
        _value = value(tree, alloc)
        if t < _value
            _parent = tree
            tree = left(tree, alloc)
        elseif t > _value
            _parent = tree
            tree = right(tree, alloc)
        else
            break
        end
    end
    _balance = false
    _update = false
    if tree !== 0
        _balance = true
        _update = true
        _left = left(tree, alloc)
        _right = right(tree, alloc)
        if _left === 0 && _right === 0
            deallocate(tree, alloc)
            tree = 0
        elseif _left === 0
            alloc[tree] = alloc[_right]
            parent!(tree, _parent, alloc)
            deallocate(_right, alloc)
        elseif _right === 0
            alloc[tree] = alloc[_left]
            parent!(tree, _parent, alloc)
            deallocate(_left, alloc)
        else
            height_left = height(_left, alloc)
            height_right = height(_right, alloc)
            if height_left >= height_right
                _value = getrightmost(_left, alloc)
                value!(tree, _value, alloc)
                parent!(_left, 0, alloc)
                _left = delete(_left, _value, alloc)
                if _left !== 0
                    parent!(_left, tree, alloc)
                end
                left!(tree, _left, alloc)
                height!(tree, alloc)
                _height = height(tree, alloc)
                tree = balance(tree, alloc)
                _balance = height(tree, alloc) !== _height
            else
                _value = getleftmost(_right, alloc)
                value!(tree, _value, alloc)
                parent!(_right, 0, alloc)
                _right = delete(_right, _value, alloc)
                if _right !== 0
                    parent!(_right, tree, alloc)
                end
                right!(tree, _right, alloc)
                height!(tree, alloc)
                _height = height(tree, alloc)
                tree = balance(tree, alloc)
                _balance = height(tree, alloc) !== _height
            end
        end
    end
    while _parent !== 0
        if _update
            _value = value(_parent, alloc)
            if t < _value
                left!(_parent, tree, alloc)
            elseif t > _value
                right!(_parent, tree, alloc)
            end
            if _balance
                _height = height(_parent, alloc)
                _parent = balance(_parent, alloc)
                _balance = height(_parent, alloc) !== _height
            else
                _update = false
            end
        end
        tree = _parent
        _parent = parent(_parent, alloc)
    end
    tree
end
