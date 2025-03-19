function policy(arr::Matrix, s_idx::Int)
    σ = arr[s_idx,:]
    return σ ./= sum(σ)
end

POMDPTools.SparseTabularMDP(game::POMG, policy_player, policy) = POMDPTools.SparseTabularMDP(
    MarkovGames.SparseTabularMG(game), policy_player, policy
)

function POMDPTools.SparseTabularMDP(game::SparseTabularMG, policy_player, policy)
    T = mdp_transitions(game, policy_player, policy)
    R = mdp_reward(game, policy_player, policy)
    b0 = vectorized_initialstate(game)
    terminal_states = vectorized_terminal(game)
    return POMDPTools.SparseTabularMDP(T, R, b0, terminal_states, discount(game))
end

function mdp_transitions(game, policy_player, policy)
    A_i = actions(game)[MarkovGames.other_player(policy_player)]
    return map(A_i) do a
        fill_transitions!(game, a, policy_player, policy)
    end
end

function fill_transitions!(game, a_i, policy_player, σ_mat)
    S = states(game)
    A = actions(game)
    ns = length(S)
    transmat_row = Int64[]
    transmat_col = Int64[]
    transmat_data = Float64[]
    A_ni = A[policy_player]

    for (s_idx, s) ∈ enumerate(S)
        if isterminal(game, s)
            push!(transmat_row, s_idx)
            push!(transmat_col, s_idx)
            push!(transmat_data, 1.0)
        else
            σ_ni = policy(σ_mat, s)
            Tsa = spzeros(ns)
            for (a_ni, σ_ni_a) ∈ zip(A_ni, σ_ni)
                a = isone(policy_player) ? (a_ni, a_i) : (a_i, a_ni)
                T = transition(game, s, a) # MUST be sparsecat, bc it's coming from SparseTabularMG
                Tsa += SparseVector(ns, Array(T.vals), σ_ni_a .* T.probs)
                # Tsa += sparsevec(T.vals, σ_ni_a .* T.probs, ns)
            end
            for (sp_idx, p) ∈ zip(Tsa.nzind, Tsa.nzval)
                push!(transmat_row, sp_idx)
                push!(transmat_col, s_idx)
                push!(transmat_data, p)
            end
        end
    end
    # FIXME: this is fuckin trash lmao
    return sparse(sparse(transmat_row, transmat_col, transmat_data, ns, ns)')
end

function mdp_reward(game, policy_player, σ_mat)
    S = states(game)
    A = actions(game)
    A_i = A[MarkovGames.other_player(policy_player)]
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
    A_i = A[MarkovGames.other_player(policy_player)]
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
