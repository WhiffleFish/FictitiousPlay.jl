Base.@kwdef struct FictitiousPlaySolver{VI}
    iter::Int = 100
    vi_solver::VI = SparseValueIterationSolver(max_iterations=1000, belres=1e-3)
    norm::Bool = true
end

# TODO: Extremely slow policy cache - use sparser implementation
# Currently have policy cache for simultaneous updates
function POMDPs.solve(sol::FictitiousPlaySolver, game)
    sparse_game = SparseTabularMG(game)
    S = states(sparse_game)
    A1, A2 = actions(sparse_game)
    policy_totals = (ones(length(S), length(A1)), ones(length(S), length(A2)))
    policy_cache = (zeros(length(S), length(A1)), zeros(length(S), length(A2)))
    for i ∈ 1:sol.iter
        for p ∈ 1:2
            mdp = POMDPTools.SparseTabularMDP(sparse_game, p, policy_totals[p])
            vi_policy = solve(sol.vi_solver, mdp)
            update_policy!(policy_cache[p] .= 0.0, vi_policy)
        end
        for p ∈ 1:2
            policy_totals[p] .+= policy_cache[p]
        end
    end
    sol.norm && for p ∈ 1:2
        foreach(eachrow(policy_totals[p])) do row
            normalize!(row, 1)
        end
    end
    return FictitiousPlayPolicy(policy_totals, game, actions(game), sol.norm)
end

function update_policy!(policy_mat::Matrix, vi_policy::ValueIterationPolicy)
    @assert eachindex(vi_policy.policy) == axes(policy_mat, 1) """
        $(eachindex(vi_policy.policy))
        $(axes(policy_mat, 1))
    """
    for s ∈ eachindex(vi_policy.policy)
        a = vi_policy.policy[s]
        policy_mat[s, a] = 1.0
    end
    policy_mat
end
