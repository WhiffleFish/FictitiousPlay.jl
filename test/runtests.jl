using FictitiousPlay
using POMGs
using POMGs.Games

@testset "smoke" begin
    game = CompetitiveTiger()
    pol = [
        0.25 0.25 0.25 0.25;
        0.25 0.25 0.25 0.25;
    ]
    pol_player = 1

    POMDPTools.SparseTabularMDP(game, pol_player, pol)
end
