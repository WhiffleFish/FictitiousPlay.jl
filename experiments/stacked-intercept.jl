begin 
    using Pkg
    Pkg.activate(dirname(@__DIR__))
    using FictitiousPlay
    using POMDPTools
    using DiscreteValueIteration
    using LinearAlgebra
    Pkg.activate(@__DIR__)
    using MarkovGames
    using POSGModels
    using POSGModels.StackedIntercept
    using POMDPs
    using Plots
    default(grid=false, framestyle=:box, fontfamily="Computer Modern", label="")
    using RecipesBase
    using StaticArrays
end

game = StackedInterceptMG()
sol = FictitiousPlaySolver(verbose=true, iter=20, vi_solver = SparseValueIterationSolver(max_iterations=1000, belres=1e-3, verbose=true))
pol = FictitiousPlay.solve(sol, game)

function clean_policy!(mat, thresh = minimum(mat)+eps())
    mat[mat .≤ thresh] .= 0
    foreach(eachrow(mat)) do row
        normalize!(row, 1)
    end
    return mat
end

clean_policy!.(pol.policy_mats)

function gen_steps(game, pol::FictitiousPlayPolicy; max_steps=typemax(Int), s=rand(initialstate(game)))
    s_hist = []
    a_hist = []
    r_hist = Float64[]
    steps = Any[(;sp=s)]
    step = 0
    while step < max_steps && !isterminal(game, s)
        step += 1
        a_joint = FictitiousPlay.joint_action(pol, s)
        sp, r = @gen(:sp, :r)(game, s, a_joint)
        r = first(r)
        a = first(a_joint)
        push!(steps, (;a, sp, r))
        push!.((s_hist, a_hist, r_hist),(s, a, r))
        s = sp
    end
    return (;s=s_hist, a=a_hist, r=r_hist)
end

function action_lines(x::Coord)
    return map(StackedIntercept.ACTION_DIRS) do a
        sp = x + a
        [x[1], sp[1]], [x[2], sp[2]]
    end
end

@recipe function f(game::StackedInterceptMG, pol::FictitiousPlayPolicy, s::StackedInterceptState)
    (;attackers, defender) = s
    attacker1, attacker2 = attackers
    s_idx = stateindex(game, s)
    _pol1 = reshape(pol.policy_mats[1][s_idx, :], (4,4))
    pol11 = vec(sum(_pol1, dims=2)) |> permutedims
    pol12 = vec(sum(_pol1, dims=1)) |> permutedims
    pol2 = pol.policy_mats[2][s_idx, :] |> permutedims
    xlims --> (0, game.floor[1]+1)
    ylims --> (0, game.floor[2]+1)
    xticks --> nothing
    yticks --> nothing
    goals = collect(game.goal)
    @series begin
        c       --> 1
        lw      --> 10
        alpha   --> pol11
        action_lines(attacker1)
    end
    @series begin
        c       --> 2
        lw      --> 10
        alpha   --> pol12
        action_lines(attacker2)
    end
    @series begin
        c       --> :red
        lw      --> 10
        alpha   --> pol2
        action_lines(defender)
    end
    @series begin
        seriestype  := :scatter
        c           --> [1,2,:red]
        [attackers[1][1], attackers[2][1], defender[1]], [attackers[1][2], attackers[2][2], defender[2]]
    end
    @series begin
        seriestype := :scatter
        ms := 20
        c := :yellow
        first.(goals), last.(goals)
    end
end

# can change initial state as desired
s0 = StackedInterceptState(SA[Coord(1,1), Coord(1,1)], Coord(5,5), false)
# e.g. put attackers and (10,7) and (11,6) and defender at (5,5)
# s0 = StackedInterceptState(SA[Coord(10,7), Coord(11,6)], Coord(5,5), false)
steps = gen_steps(game, pol; max_steps=30, s=s0)

anim = @animate for s in steps.s
    plot(game, pol, s, xlims=(0, game.floor[1]+1), ylims=(0, game.floor[2]+1))
end

gif(anim, "stacked-intercept.gif", fps=5)


# plot an individual step
plot(game, pol, steps.s[15])

