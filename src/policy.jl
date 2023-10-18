struct FictitiousPlayPolicy{G,A}
    policy_mats::NTuple{2, Matrix{Float64}}
    game::G
    action_map::A
    normed::Bool
end

function player_policy(pol::FictitiousPlayPolicy, p, s)
    pol_mat = pol.policy_mats[p]
    s_idx = stateindex(pol.game, s)
    σ = policy(pol_mat, s_idx)
    return POMDPTools.SparseCat(σ, pol.action_map)
end

function policies(pol::FictitiousPlayPolicy, s)
    return player_policy(pol, 1, s), player_policy(pol, 2, s)
end

function player_action(pol::FictitiousPlayPolicy, p, s)
    return rand(player_policy(pol, p, s))
end

joint_action(pol::FictitiousPlayPolicy, s) = rand.(policies(pol, s))
