begin
    using Pkg
    Pkg.activate(dirname(@__DIR__))
    using FictitiousPlay
    Pkg.activate(@__DIR__)
    using POMGs
    using POMGs.Games
    import POMDPTools
end

game = CompetitiveTiger()
pol = [
    0.25 0.25 0.25 0.25;
    0.25 0.25 0.25 0.25;
]
pol_player = 1

POMDPTools.SparseTabularMDP(game, pol_player, pol)
sparse_game = POMGs.SparseTabularMG(game)
actions(sparse_game)
nonzeros(sparse_game.isterminal)
nzind, nzval = findnz(sparse_game.isterminal)
