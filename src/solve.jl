Base.@kwdef struct FictitiousPlaySolver{VI}
    iter::Int = 100
    vi_solver::VI = SparseValueIterationSolver(max_iterations=100, belres=1e-3)
end

POMDPs.solve(sol::FictitiousPlaySolver, game::POMG) = solve(sol, SparseTabularMG(game))

function POMDPs.solve(sol::FictitiousPlaySolver, game::SparseTabularMG)
    S = states(game)
    A1, A2 = actions(game)
    policy_totals = (ones(length(S), length(A1)), ones(length(S), length(A2)))
    for i ∈ 1:sol.iter
        for p ∈ 1:2
            mdp = POMDPTools.SparseTabularMDP(game, p, policy_totals[p])
            vi_policy = solve(sol.vi_solver, mdp)
            update_policy!(policy_totals[p], vi_policy)
        end
    end
    return policy_totals
end

function update_policy!(policy_mat::Matrix, vi_policy::ValueIterationPolicy)
    @assert eachindex(vi_policy.policy) == axes(policy_mat, 1) """
        $(eachindex(vi_policy.policy))
        $(axes(policy_mat, 1))
    """
    for s ∈ eachindex(vi_policy.policy)
        a = vi_policy.policy[s]
        policy_mat[s, a] += 1.0
    end
    policy_mat
end
