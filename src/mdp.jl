function policy(arr::Matrix, s_idx::Int)
    σ = arr[s_idx,:]
    return σ ./= sum(σ)
end

POMDPTools.SparseTabularMDP(game::POMG, policy_player, policy) = POMDPTools.SparseTabularMDP(POMGs.SparseTabularMG(game), policy_player, policy)

function POMDPTools.SparseTabularMDP(game::SparseTabularMG, policy_player, policy)
    T = mdp_transitions(game, policy_player, policy)
    R = mdp_reward(game, policy_player, policy)
    b0 = vectorized_initialstate(game)
    terminal_states = vectorized_terminal(game)
    return POMDPTools.SparseTabularMDP(T, R, b0, terminal_states, discount(game))
end

function mdp_transitions(game, policy_player, policy)
    S = states(game)
    A = actions(game)
    A_i = A[POMGs.other_player(policy_player)]
    T = [zeros(S, S) for _ in A_i] # T[a][s, sp]
    for (a,Ta) in enumerate(T)
        fill_transitions!(game, Ta, a, policy_player, policy)
    end
    return T
end

function fill_transitions!(game, Ta, a_i, policy_player, σ_mat)
    S = states(game)
    A = actions(game)
    A_ni = A[policy_player]
    Ta .= 0.0
    for s ∈ S
        if isterminal(game, s)
            Ta[s,s] = 1.0
        else
            σ_ni = policy(σ_mat, s)
            for a_ni ∈ A_ni
                a = isone(policy_player) ? (a_ni, a_i) : (a_i, a_ni)
                # game.T[a1, a2][sp, s]
                @views Ta[s,:] .+= σ_ni[a_ni] .* game.T[a...][:, s]
            end
        end
    end
    return Ta
end

function mdp_reward(game, policy_player, σ_mat)
    S = states(game)
    A = actions(game)
    A_i = A[POMGs.other_player(policy_player)]
    R = zeros(length(S), length(A_i))
    return fill_reward!(game, R, policy_player, σ_mat) 
end

function vectorized_initialstate(game::SparseTabularGame)
    return game.initialstate
end

function vectorized_terminal(game::SparseTabularGame)
    nzind, nzval = findnz(game.isterminal)
    return Set(nzind)
end

function fill_reward!(game::SparseTabularGame, R, policy_player, σ_mat)
    S = states(game)
    A = actions(game)
    A_i = A[POMGs.other_player(policy_player)]
    for s ∈ S
        # TODO: check terminal
        σ_ni = policy(σ_mat, s)
        for a_i ∈ A_i
            # TODO: use views
            if isone(policy_player)
                v = -dot(game.R[s, :, a_i], σ_ni)
                R[s, a_i] = v
            else
                R[s, a_i] = dot(game.R[s, a_i, :], σ_ni)
            end
        end
    end
    R
end
