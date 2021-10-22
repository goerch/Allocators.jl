const Height = Int8
const TreeNode{T, I, D} = Tuple{T, I, I, I, Height, D}

mutable struct Node{T, D}
    value::T
    left::Union{Nothing, Node{T, D}}
    right::Union{Nothing, Node{T, D}}
    parent::Union{Nothing, Node{T, D}}
    height::Height
    data::D
end
const Tree{T, D} = Union{Nothing, Node{T, D}}

nil() = nothing
node(t::T, left, right, parent, height, data::D) where {T, D} =
    Node{T, D}(t, left, right, parent, height, data)

nil(alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}} = 0
node(t::T, left, right, parent, height, data::D, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}} =
    allocateend!(alloc, (t, left, right, parent, height, data))

deallocate(i::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}} =
    deallocate!(alloc, i)

@inline value(tree::Nothing) = @assert false
@inline function value(tree::Node{T, D}) where {T, D}
    tree.value
end

@inline left(tree::Nothing) = @assert false
@inline function left(tree::Node{T, D}) where {T, D}
    tree.left
end

@inline right(tree::Nothing) = @assert false
@inline function right(tree::Node{T, D}) where {T, D}
    tree.right
end

@inline Base.parent(tree::Nothing) = @assert false
@inline function Base.parent(tree::Node{T, D}) where {T, D}
    tree.parent
end

@inline height(tree::Nothing) = Height(0)
@inline height(tree::Node{T, D}) where {T, D} = tree.height

@inline data(tree::Nothing) = @assert false
@inline data(tree::Node{T, D}) where {T, D} = tree.data

@inline value!(tree::Nothing, left::Tree{T}) where {T, D} = @assert false
@inline function value!(tree::Node{T, D}, value::T) where {T, D}
    tree.value = value
end

@inline left!(tree::Nothing, left::Tree{T}) where {T, D} = @assert false
@inline function left!(tree::Node{T, D}, left::Tree{T}) where {T, D}
    tree.left = left
end

@inline right!(tree::Nothing, right::Tree{T}) where {T, D} = @assert false
@inline function right!(tree::Node{T, D}, right::Tree{T}) where {T, D}
    tree.right = right
end

@inline parent!(tree::Nothing, parent::Tree{T}) where {T, D} = @assert false
@inline function parent!(tree::Node{T, D}, parent::Tree{T}) where {T, D}
    tree.parent = parent
end

@inline height!(tree::Nothing, height_left::Height, height_right::Height) = @assert false
@inline function height!(tree::Node{T, D}, height_left::Height, height_right::Height) where {T, D}
    tree.height = max(height_left, height_right) + Height(1)
end

@inline height!(tree::Nothing) = @assert false
@inline function height!(tree::Node{T, D}) where {T, D}
    height!(tree, height(tree.left), height(tree.right))
end

@inline data!(tree::Nothing, data::D) where {T, D} = @assert false
@inline function data!(tree::Node{T, D}, data::D) where {T, D}
    tree.data = data
end

@inline function value(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    tree === 0 ? (@assert false) : alloc[tree][1]
end

@inline function left(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    tree === 0 ? (@assert false) : alloc[tree][2]
end

@inline function right(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    tree === 0 ? (@assert false) : alloc[tree][3]
end

@inline function Base.parent(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    tree === 0 ? (@assert false) : alloc[tree][4]
end

@inline function height(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    tree === 0 ? Height(0) : alloc[tree][5]
end

@inline function data(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    tree === 0 ? (@assert false) : alloc[tree][6]
end

@inline function value!(tree::I, _value::T, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree !== 0
        node = alloc[tree]
        # if _value != node[1]
            t = (_value, node[2], node[3],
                 node[4], node[5], node[6])
            setindex!(alloc, t, tree)
        # end
    else
        @assert false
    end
end

@inline function left!(tree::I, _left::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree !== 0
        node = alloc[tree]
        # if _left != node[2]
            t = (node[1], _left, node[3],
                 node[4], node[5], node[6])
            setindex!(alloc, t, tree)
        # end
    else
        @assert false
    end
end

@inline function right!(tree::I, _right::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree !== 0
        node = alloc[tree]
        # if _right != node[3]
            t = (node[1], node[2], _right,
                 node[4], node[5], node[6])
            setindex!(alloc, t, tree)
        # end
    else
        @assert false
    end
end

@inline function parent!(tree::I, _parent::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree !== 0
        node = alloc[tree]
        # if _parent != node[4]
            t = (node[1], node[2], node[3],
                 _parent, node[5], node[6])
            setindex!(alloc, t, tree)
        # end
    else
        @assert false
    end
end

@inline function height!(tree::I, _left::I, _right::I, height_left::Height, height_right::Height, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree !== 0
        _height = max(height_left, height_right) + Height(1)
        node = alloc[tree]
        # if _height != node[5]
            t = (node[1], _left, _right,
                 node[4], _height, node[6])
            setindex!(alloc, t, tree)
        # end
    else
        @assert false
    end
end

@inline function height!(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree !== 0
        _left = left(tree, alloc)
        _right = right(tree, alloc)
        height_left = height(_left, alloc)
        height_right = height(_right, alloc)
        height!(tree, _left, _right, height_left, height_right, alloc)
    else
        @assert false
    end
end

@inline function data!(tree::I, _data::D, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree !== 0
        node = alloc[tree]
        # if _data != node[6]
            t = (node[1], node[2], node[3],
                 node[4], node[5], _data)
            setindex!(alloc, t, tree)
        # end
    else
        @assert false
    end
end

invariantvalue(tree::Nothing) = true
function invariantvalue(tree::Node{T, D}) where {T, D}
    invariant = true
    _value = value(tree)
    _left = left(tree)
    invariant &= _left === nothing || value(_left) < _value
    _right = right(tree)
    invariant &= _right === nothing || value(_right) > _value
    @assert invariant
    invariant
end

invariantparent(tree::Nothing) = true
function invariantparent(tree::Node{T, D}) where {T, D}
    invariant = true
    _left = left(tree)
    invariant &= _left === nothing || parent(_left) === tree
    _right = right(tree)
    invariant &= _right === nothing || parent(_right) === tree
    @assert invariant
    invariant
end

invariantheight(tree::Nothing) = true
function invariantheight(tree::Node{T, D}) where {T, D}
    _left = left(tree)
    _right = right(tree)
    _height = height(tree)
    height_left = height(_left)
    height_right = height(_right)
    @assert _height == max(height_left, height_right) + 1
    invariant = abs(height_left - height_right) < 2
    @assert invariant
    invariant
end

function invariantvalue(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree === 0
        return true
    else
        invariant = true
        _value = value(tree, alloc)
        _left = left(tree, alloc)
        invariant &= _left === 0 || value(_left, alloc) < _value
        _right = right(tree, alloc)
        invariant &= _right === 0 || value(_right, alloc) > _value
        @assert invariant
        invariant
    end
end

function invariantparent(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree === 0
        return true
    else
        invariant = true
        _left = left(tree, alloc)
        invariant &= _left === 0 || parent(_left, alloc) === tree
        _right = right(tree, alloc)
        invariant &= _right === 0 || parent(_right, alloc) === tree
        @assert invariant
        invariant
    end
end

function invariantheight(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree === 0
        return true
    else
        _left = left(tree, alloc)
        _right = right(tree, alloc)
        _height = height(tree, alloc)
        height_left = height(_left, alloc)
        height_right = height(_right, alloc)
        @assert _height == max(height_left, height_right) + 1
        invariant = abs(height_left - height_right) < 2
        @assert invariant
        invariant
    end
end

@inline function rotateright(tree::Node{T, D}) where {T, D}
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
@inline function rotateleft(tree::Node{T, D})  where {T, D}
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

@inline function rotateright(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
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
@inline function rotateleft(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
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

@inline balance(tree::Nothing) = nothing
@inline function balance(tree::Node{T, D}) where {T, D}
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
        height!(tree, height_left, height_right)
    end
    tree
end

@inline function balance(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
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
        height!(tree, _left, _right, height_left, height_right, alloc)
    end
    tree
end

function insert(tree::Tree{T}, t::T, data::D) where {T, D}
    _root = tree
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
        tree = node(t, nothing, nothing, _parent, 1, data)
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
        else
            return _root
        end
        tree = _parent
        _parent = parent(tree)
    end
    return tree
end

function insert(tree::I, t::T, data::D, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    _root = tree
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
        tree = node(t, 0, 0, _parent, Height(1), data, alloc)
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
        else
            return _root
        end
        tree = _parent
        _parent = parent(tree, alloc)
    end
    return tree
end

@inline Base.haskey(tree::Nothing, t::T) where {T, D} = false
@inline function Base.haskey(tree::Node{T, D}, t::T) where {T, D}
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

@inline function Base.haskey(tree::I, t::T, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
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

@inline Base.getindex(tree::Nothing, t::T) where {T, D} = false
@inline function Base.getindex(tree::Node{T, D}, t::T) where {T, D}
    while tree !== nothing
        _value = value(tree)
        if t < _value
            tree = left(tree)
        elseif t > _value
            tree = right(tree)
        else
            return data(tree)
        end
    end
    @assert false
end

@inline function Base.haskey(tree::I, t::T, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
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

@inline function Base.getindex(tree::I, t::T, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    while tree !== 0
        _value = value(tree, alloc)
        if t < _value
            tree = left(tree, alloc)
        elseif t > _value
            tree = right(tree, alloc)
        else
            return data(tree, alloc)
        end
    end
    @assert false
end

@inline getleftmost(::Nothing) = @assert false
@inline function getleftmost(tree::Node{T, D}) where {T, D}
    _left = left(tree)
    while _left !== nothing
        tree = _left
        _left = left(tree)
    end
    value(tree)
end

@inline getrightmost(::Nothing) = @assert false
@inline function getrightmost(tree::Node{T, D}) where {T, D}
    _right = right(tree)
    while _right !== nothing
        tree = _right
        _right = right(tree)
    end
    value(tree)
end

@inline function getleftmost(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    _left = left(tree, alloc)
    while _left !== 0
        tree = _left
        _left = left(tree, alloc)
    end
    value(tree, alloc)
end

@inline function getrightmost(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    _right = right(tree, alloc)
    while _right !== 0
        tree = _right
        _right = right(tree, alloc)
    end
    value(tree, alloc)
end

function delete(tree::Tree{T}, t::T) where T
    _root = tree
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
            data!(tree, data(_right))
            if _left !== nothing
                parent!(_left, tree)
            end
            _right = right(tree)
            if _right !== nothing
                parent!(_right, tree)
            end
        elseif _right === nothing
            value!(tree, value(_left))
            left!(tree, left(_left))
            right!(tree, right(_left))
            height!(tree)
            data!(tree, data(_left))
            _left = left(tree)
            if _left !== nothing
                parent!(_left, tree)
            end
            _right = right(tree)
            if _right !== nothing
                parent!(_right, tree)
            end
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
            else
                _value = getleftmost(_right)
                value!(tree, _value)
                parent!(_right, nothing)
                _right = delete(_right, _value)
                if _right !== nothing
                    parent!(_right, tree)
                end
                right!(tree, _right)
                height!(tree)
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
        else
            return _root
        end
        tree = _parent
        _parent = parent(tree)
    end
    return tree
end

function delete(tree::I, t::T, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    _root = tree
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
            _left = left(tree, alloc)
            if _left !== 0
                parent!(_left, tree, alloc)
            end
            _right = right(tree, alloc)
            if _right !== 0
                parent!(_right, tree, alloc)
            end
        elseif _right === 0
            alloc[tree] = alloc[_left]
            parent!(tree, _parent, alloc)
            deallocate(_left, alloc)
            _left = left(tree, alloc)
            if _left !== 0
                parent!(_left, tree, alloc)
            end
            _right = right(tree, alloc)
            if _right !== 0
                parent!(_right, tree, alloc)
            end
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
        else
            return _root
        end
        tree = _parent
        _parent = parent(_parent, alloc)
    end
    return tree
end
