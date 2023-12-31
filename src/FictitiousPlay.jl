module FictitiousPlay

using LinearAlgebra
using SparseArrays
using DiscreteValueIteration
using POMGs
import POMDPs
import POMDPTools
using ProgressMeter

include("sparse_tools.jl")

include("mdp.jl")

include("solve.jl")
export FictitiousPlaySolver

include("policy.jl")
export FictitiousPlayPolicy

include("value.jl")
export policy_value

end # module FictitiousPlay
