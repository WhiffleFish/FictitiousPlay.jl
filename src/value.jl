Base.@kwdef struct PolicyEvaluator
    iter::Int           = 100
    bel_res::Float64    = 1e-3
    max_time::Float64   = Inf
    verbose::Bool       = false
end

PolicyEvaluator(sol::FictitiousPlaySolver; kwargs...) = PolicyEvaluator(;iter=sol.iter, verbose=sol.verbose, kwargs...)

policy_value(eval::PolicyEvaluator, pol::FictitiousPlayPolicy, game) = policy_value(eval, pol.policy_mats, game)

function policy_value(eval::PolicyEvaluator, policy_mats::Tuple, game::Game)
    game = SparseTabularMG(game)
    # TODO: assert that policy is normed already
    V = zeros(length(states(game)))
    γ = discount(game)
    A1, A2 = actions(game)
    iter = 0
    t0 = time()
    
    prog = Progress(eval.iter; enabled=eval.verbose)
    while iter < eval.iter && time() - t0 < eval.max_time
        for s ∈ eachindex(V)
            for a1 ∈ A1
                π1 = policy_mats[1][s, a1]
                for a2 ∈ A2
                    π2 = policy_mats[2][s, a2]
                    # T[a1, a2][sp, s]
                    V[s] = π1*π2*(game.R[s, a1, a2] + γ * dot(@view(game.T[a1, a2][:, s]), V)) 
                end
            end
        end
        iter += 1
        next!(prog)
    end
    finish!(prog)
    return V
end
