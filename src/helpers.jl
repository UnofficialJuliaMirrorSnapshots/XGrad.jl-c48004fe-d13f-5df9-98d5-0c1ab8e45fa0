## helpers.jl - exported functions used in generated code

function ungetindex!(dx::AbstractArray, x::AbstractArray, ds, i...)
    dx[[i...]] .= ds
    return dx
end

function ungetindex!(dx::AbstractArray, x::AbstractArray, ds, i::AbstractArray{Int})
    dx[i] .= ds
    return dx
end


function ungetindex(x::AbstractArray, ds, i...)
    dx = zero(x)
    return ungetindex!(dx, x, ds, i...)
end


function sum_grad(x::AbstractArray, ds; opts...)
    return ones(size(x)) .* ds
end
