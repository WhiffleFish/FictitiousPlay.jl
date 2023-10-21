"""
ASSUMES THAT dest is already all zeros! (or at least that the sparsity pattern is preserved)
"""
function sparse_col_mul!(dest::AbstractVector, v::AbstractVector, mat::SparseMatrixCSC, col::Int)
    @assert length(dest) == length(v) == size(mat, 1)
    r1 = convert(Int, SparseArrays.getcolptr(mat)[col])
    r2 = convert(Int, SparseArrays.getcolptr(mat)[col+1]) - 1
    
    rvs = rowvals(mat)
    nzs = nonzeros(mat)

    for _idx ∈ r1:r2
        idx = rvs[_idx]
        mat_val = nzs[_idx]
        dest[idx] = mat_val * v[idx]
    end
    dest
end

function sparse_col_muladd!(dest::AbstractVector, a::Number, mat::SparseMatrixCSC, col::Int)
    @assert length(dest) == size(mat, 1)
    r1 = convert(Int, SparseArrays.getcolptr(mat)[col])
    r2 = convert(Int, SparseArrays.getcolptr(mat)[col+1]) - 1
    
    rvs = rowvals(mat)
    nzs = nonzeros(mat)

    for _idx ∈ r1:r2
        idx = rvs[_idx]
        mat_val = nzs[_idx]
        dest[idx] += mat_val * a
    end
    dest
end
