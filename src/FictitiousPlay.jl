module FictitiousPlay

using LinearAlgebra
using SparseArrays
using DiscreteValueIteration
using POMGs
import POMDPs
import POMDPTools

include("mdp.jl")

include("solve.jl")
export FictitiousPlaySolver

end # module FictitiousPlay
