struct FictitiousPlaySolver

end

POMDPs.solve(sol::FictitiousPlaySolver, game::POMG) = solve(sol, SparseTabularMG(game))

function POMDPs.solve(sol::FictitiousPlaySolver, game::SparseTabularMG)
    S = states(game)
    A1, A2 = actions(game)
    # S × A1 × A2
    policy_totals = (ones(length(S), length(A1)), ones(length(S), length(A2)))

end
