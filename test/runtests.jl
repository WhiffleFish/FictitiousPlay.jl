using FictitiousPlay
using MarkovGames
using MarkovGames.Games
using POMDPTools
using Test

@testset "smoke" begin
    game = CompetitiveTiger()
    pol = [
        0.25 0.25 0.25 0.25;
        0.25 0.25 0.25 0.25;
    ]
    pol_player = 1

    POMDPTools.SparseTabularMDP(game, pol_player, pol)
end
