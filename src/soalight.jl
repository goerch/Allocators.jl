struct TupleVector{T, V <: Tuple} <: AbstractVector{T}
    vectors::V
    function TupleVector{T, V}(v) where {T, V <: Tuple}
        new{T, V}(v)
    end
end

Base.size(tv::TupleVector{T, V}) where {T, V} =
    min([length(vector) for vector in tv.vectors]...)

@generated function TupleVector{T}(n::I) where {T, I}
    types = fieldtypes(T)
    V = Tuple{(Vector{type} for type in types)...}
    args = [:(Vector{$type}(undef, n)) for type in types]
    :(TupleVector{T, $V}(($(args...),)))
end

@generated function Base.getindex(tv::TupleVector{T}, i::I) where {T, I}
    types = fieldtypes(T)
    members = [:(tv.vectors[$index][i])
               for (index, type) in enumerate(types)]
    Expr(:block, Expr(:meta, :inline), Expr(:new, T, members...))
end

@generated function Base.setindex!(tv::TupleVector{T}, t::T, i::I) where {T, I}
    types = fieldtypes(T)
    expressions = [:(tv.vectors[$index][i] = getfield(t, $index))
                   for (index, type) in enumerate(types)]
    :($(Expr(:block, Expr(:meta, :inline), expressions...)), t)
end

@noinline function resizeend!(tv::TupleVector{T}, n::I) where {T, I}
    if n > length(tv)
        for (i, _) in enumerate(tv.vectors)
            Base._growend!(tv.vectors[i], n - length(tv))
        end
    elseif n < length(tv)
        for (i, _) in enumerate(tv.vectors)
            Base._deleteend!(tv.vectors[i], length(tv) - n)
        end
    end
end
@noinline function resizebegin!(tv::TupleVector{T}, n::I) where {T, I}
    if n > length(tv)
        for (i, _) in enumerate(tv.vectors)
            Base._growbeg!(tv.vectors[i], n - length(tv))
        end
    elseif n < length(tv)
        for (i, _) in enumerate(tv.vectors)
            Base._deletebeg!(tv.vectors[i], length(tv) - n)
        end
    end
end
