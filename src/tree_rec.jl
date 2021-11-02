const Height = Int8
const TreeNode{T, I, D} = Tuple{T, I, I, Height, D}

mutable struct Node{T, D}
    value::T
    left::Union{Nothing, Node{T, D}}
    right::Union{Nothing, Node{T, D}}
    height::Height
    data::D
end
const Tree{T, D} = Union{Nothing, Node{T, D}}

@inline nil() = nothing
@inline node(t::T, data::D) where {T, D} =
    Node{T, D}(t, nothing, nothing, Height(1), data)
@inline node(t::T, left, right, height, data::D) where {T, D} =
    Node{T, D}(t, left, right, height, data)

@inline nil(alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}} = 0
@inline node(t::T, data::D, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}} =
    allocateend!(alloc, (t, 0, 0, Height(1), data))
@inline node(t::T, left, right, height, data::D, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}} =
    allocateend!(alloc, (t, left, right, height, data))

@inline deallocate(i::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}} =
    deallocate!(alloc, i)

# @inline value(tree::Nothing) = @assert false
@inline value(tree::Node{T, D}) where {T, D} = tree.value

# @inline left(tree::Nothing) = @assert false
@inline left(tree::Node{T, D}) where {T, D} = tree.left

# @inline right(tree::Nothing) = @assert false
@inline right(tree::Node{T, D}) where {T, D} = tree.right

@inline height(tree::Nothing) = Height(0)
@inline height(tree::Node{T, D}) where {T, D} = tree.height

# @inline data(tree::Nothing) = @assert false
@inline data(tree::Node{T, D}) where {T, D} = tree.data

# @inline value!(tree::Nothing, left::Tree{T}) where {T, D} = @assert false
@inline function value!(tree::Node{T, D}, value::T) where {T, D}
    tree.value = value
end

# @inline left!(tree::Nothing, left::Tree{T}) where {T, D} = @assert false
@inline function left!(tree::Node{T, D}, left::Tree{T}) where {T, D}
    tree.left = left
end

# @inline right!(tree::Nothing, right::Tree{T}) where {T, D} = @assert false
@inline function right!(tree::Node{T, D}, right::Tree{T}) where {T, D}
    tree.right = right
end

# @inline height!(tree::Nothing, height::Height) = @assert false
@inline function height!(tree::Node{T, D}, height::Height) where {T, D}
    tree.height = height
end

# @inline height!(tree::Nothing, height_left::Height, height_right::Height) = @assert false
@inline function height!(tree::Node{T, D}, height_left::Height, height_right::Height) where {T, D}
    tree.height = max(height_left, height_right) + Height(1)
end

# @inline height!(tree::Nothing) = @assert false
@inline function height!(tree::Node{T, D}) where {T, D}
    _left = left(tree)
    _right = right(tree)
    height!(tree, height(_left), height(_right))
end

# @inline data!(tree::Nothing, data::D) where {T, D} = @assert false
@inline function data!(tree::Node{T, D}, data::D) where {T, D}
    tree.data = data
end

@inline function value(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    alloc[tree][1]
end
@inline function value(tree::I, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    alloc[tree, 1]
end

@inline function left(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    alloc[tree][2]
end
@inline function left(tree::I, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    alloc[tree, 2]
end

@inline function right(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    alloc[tree][3]
end
@inline function right(tree::I, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    alloc[tree, 3]
end

@inline function height(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    tree === 0 ? Height(0) : alloc[tree][4]
end
@inline function height(tree::I, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    tree === 0 ? Height(0) : alloc[tree, 4]
end

@inline function data(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    alloc[tree][5]
end
@inline function data(tree::I, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    alloc[tree, 5]
end

@inline function value!(tree::I, _value::T, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    # if tree !== 0
        node = alloc[tree]
        # if _value != node[1]
            t = (_value, node[2], node[3],
                 node[4], node[5])
            alloc[tree] = t
        # end
    # else
    #     @assert false
    # end
end
@inline function value!(tree::I, _value::T, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    alloc[tree, 1] = _value
end

@inline function left!(tree::I, _left::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    # if tree !== 0
        node = alloc[tree]
        # if _left != node[2]
            t = (node[1], _left, node[3],
                 node[4], node[5])
            alloc[tree] = t
        # end
    # else
    #     @assert false
    # end
end
@inline function left!(tree::I, _left::I, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    alloc[tree, 2] = _left
end

@inline function right!(tree::I, _right::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    # if tree !== 0
        node = alloc[tree]
        # if _right != node[3]
            t = (node[1], node[2], _right,
                 node[4], node[5])
            alloc[tree] = t
        # end
    # else
    #     @assert false
    # end
end
@inline function right!(tree::I, _right::I, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    alloc[tree, 3] = _right
end

@inline function height!(tree::I, _height::Height, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    # if tree !== 0
        node = alloc[tree]
        # if _height != node[5]
            t = (node[1], node[2], node[3],
                 _height, node[5])
            alloc[tree] = t
        # end
    # else
    #     @assert false
    # end
end
@inline function height!(tree::I, _height::I, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    alloc[tree, 4] = _height
end

@inline function height!(tree::I, height_left::Height, height_right::Height, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    _height = max(height_left, height_right) + Height(1)
    height!(tree, _height, alloc)
end

@inline function height!(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    # if tree !== 0
        _left = left(tree, alloc)
        _right = right(tree, alloc)
        height_left = height(_left, alloc)
        height_right = height(_right, alloc)
        height!(tree, height_left, height_right, alloc)
    # else
    #     @assert false
    # end
end

@inline function data!(tree::I, _data::D, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    # if tree !== 0
        node = alloc[tree]
        # if _data != node[5]
            t = (node[1], node[2], node[3],
                 node[4], _data)
            alloc[tree] = t
        # end
    # else
    #     @assert false
    # end
end
@inline function data!(tree::I, _data::D, alloc::A) where {T, I, D, S, A <: AbstractFreeListSOAllocator{TreeNode{T, I, D}, I, S}}
    alloc[tree, 5] = _data
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
    left_right = right(_left)
    right!(_left, tree)
    left!(tree, left_right)
    # height!(tree)
    _height = height!(tree, height(left_right), height(right(tree)))
    # height!(_left)
    height!(_left, height(left(_left)), _height)
    _left
end
@inline function rotateleft(tree::Node{T, D}) where {T, D}
    _right = right(tree)
    right_left = left(_right)
    @assert _right !== nothing
    left!(_right, tree)
    right!(tree, right_left)
    # height!(tree)
    _height = height!(tree, height(left(tree)), height(right_left))
    # height!(_right)
    height!(_right, _height, height(right(_right)))
    _right
end

@inline function rotateright(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    _left = left(tree, alloc)
    left_right = right(_left, alloc)
    right!(_left, tree, alloc)
    left!(tree, left_right, alloc)
    # height!(tree, alloc)
    _right = right(tree, alloc)
    height!(tree, height(left_right, alloc), height(_right, alloc), alloc)
    # height!(_left, alloc)
    left_left = left(_left, alloc)
    height!(_left, height(left_left, alloc), height(tree, alloc), alloc)
    _left
end
@inline function rotateleft(tree::I, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    _right = right(tree, alloc)
    right_left = left(_right, alloc)
    left!(_right, tree, alloc)
    right!(tree, right_left, alloc)
    # height!(tree, alloc)
    _left = left(tree, alloc)
    height!(tree, height(_left, alloc), height(right_left, alloc), alloc)
    # height!(_right, alloc)
    right_right = right(_right, alloc)
    height!(_right, height(tree, alloc), height(right_right, alloc), alloc)
    _right
end

# @inline balance(tree::Nothing) = nothing
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
        height!(tree, height_left, height_right, alloc)
    end
    tree
end

@noinline insert(tree::Nothing, t::T, data::D) where {T, D} = node(t, data)
@noinline function insert(tree::Node{T}, t::T, data::D) where {T, D}
    _value = value(tree)
    if t < _value
        _left = left(tree)
        _height = height(_left)
        _left = insert(_left, t, data)
        left!(tree, _left)
        if height(_left) != _height
            tree = balance(tree)
        end
    elseif t > _value
        _right = right(tree)
        _height = height(_right)
        _right = insert(_right, t, data)
        right!(tree, _right)
        if height(_right) != _height
            tree = balance(tree)
        end
    else
        data!(tree, data)
    end
    tree
end

@noinline function insert(tree::I, t::T, data::D, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree !== 0
        _value = value(tree, alloc)
        if t < _value
            _left = left(tree, alloc)
            _height = height(_left, alloc)
            _left = insert(_left, t, data, alloc)
            left!(tree, _left, alloc)
            if height(_left, alloc) != _height
                tree = balance(tree, alloc)
            end
        elseif t > _value
            _right = right(tree, alloc)
            _height = height(_right, alloc)
            _right = insert(_right, t, data, alloc)
            right!(tree, _right, alloc)
            if height(_right, alloc) != _height
                tree = balance(tree, alloc)
            end
        else
            data!(tree, data, alloc)
        end
    else
        tree = node(t, data, alloc)
    end
    tree
end

# @inline Base.haskey(tree::Nothing, t::T) where {T, D} = false
@inline function Base.haskey(tree::Tree{T, D}, t::T) where {T, D}
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

@inline Base.getindex(tree::Nothing, t::T) where {T, D} = @assert false
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

@noinline delete(tree::Nothing, t::T) where T = tree
@noinline function delete(tree::Node{T, D}, t::T) where {T, D}
    _value = value(tree)
    if t < _value
        _left = left(tree)
        _height = height(_left)
        _left = delete(_left, t)
        left!(tree, _left)
        if height(_left) != _height
            tree = balance(tree)
        end
    elseif t > _value
        _right = right(tree)
        _height = height(_right)
        _right = delete(_right, t)
        right!(tree, _right)
        if height(_right) != _height
            tree = balance(tree)
        end
    else
        _left = left(tree)
        _right = right(tree)
        if _left === nothing && _right === nothing
            tree = nothing
        elseif _left === nothing
            value!(tree, value(_right))
            left!(tree, left(_right))
            right!(tree, right(_right))
            # height!(tree)
            height!(tree, height(_right))
            data!(tree, data(_right))
        elseif _right === nothing
            value!(tree, value(_left))
            left!(tree, left(_left))
            right!(tree, right(_left))
            # height!(tree)
            height!(tree, height(_left))
            data!(tree, data(_left))
        else
            height_left = height(_left)
            height_right = height(_right)
            if height_left >= height_right
                _value = getrightmost(_left)
                value!(tree, _value)
                _left = delete(_left, _value)
                left!(tree, _left)
                # height!(tree)
                height!(tree, height(_left), height_right)
            else
                _value = getleftmost(_right)
                value!(tree, _value)
                _right = delete(_right, _value)
                right!(tree, _right)
                # height!(tree)
                height!(tree, height_left, height(_right))
            end
        end
    end
    tree
end

@noinline function delete(tree::I, t::T, alloc::A) where {T, I, D, A <: AbstractFreeListAllocator{TreeNode{T, I, D}, I}}
    if tree !== 0
        _value = value(tree, alloc)
        if t < _value
            _left = left(tree, alloc)
            _height = height(_left, alloc)
            _left = delete(_left, t, alloc)
            left!(tree, _left, alloc)
            if height(_left, alloc) != _height
                tree = balance(tree, alloc)
            end
        elseif t > _value
            _right = right(tree, alloc)
            _height = height(_right, alloc)
            _right = delete(_right, t, alloc)
            right!(tree, _right, alloc)
            if height(_right, alloc) != _height
                tree = balance(tree, alloc)
            end
        else
            _left = left(tree, alloc)
            _right = right(tree, alloc)
            if _left === 0 && _right === 0
                deallocate(tree, alloc)
                tree = 0
            elseif _left === 0
                alloc[tree] = alloc[_right]
                deallocate(_right, alloc)
            elseif _right === 0
                alloc[tree] = alloc[_left]
                deallocate(_left, alloc)
            else
                height_left = height(_left, alloc)
                height_right = height(_right, alloc)
                if height_left >= height_right
                    _value = getrightmost(_left, alloc)
                    value!(tree, _value, alloc)
                    _left = delete(_left, _value, alloc)
                    left!(tree, _left, alloc)
                    # height!(tree, alloc)
           		    height!(tree, height(_left, alloc), height_right, alloc)
                else
                    _value = getleftmost(_right, alloc)
                    value!(tree, _value, alloc)
                    _right = delete(_right, _value, alloc)
                    right!(tree, _right, alloc)
                    # height!(tree, alloc)
	                height!(tree, height_left, height(_right, alloc), alloc)
                end
            end
        end
    end
    tree
end
