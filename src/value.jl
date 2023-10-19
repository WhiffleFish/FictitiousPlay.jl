Base.@kwdef struct PolicyEvaluator
    iter::Int = 100
    bel_res::Float64 = 1e-3
    max_time::Float64 = Inf
end

function policy_value(eval::PolicyEvaluator, policy_mats::Tuple, game::SparseTabularGame)
    # TODO: assert that policy is normed already
    V = zeros(length(states(game)))
    γ = discount(game)
    A1, A2 = actions(game)
    iter = 0
    t0 = time()
    
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
    end
    return V
end
