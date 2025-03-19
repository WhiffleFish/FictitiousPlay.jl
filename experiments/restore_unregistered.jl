macro restore_unregistered(Pkgname, link)
    esc(_restore_unregistered(Symbol(Pkgname), link))
end

macro restore_unregistered(Pkgname)
    esc(_restore_unregistered(Symbol(Pkgname)))
end

function _restore_unregistered(Pkgname, link)
    s_pkg = string(Pkgname)
    return quote
        try
            using $Pkgname
            println($s_pkg," already installed")
        catch e
            if e isa ArgumentError
                if occursin("not found in current path", e.msg)
                    Pkg.add(url=$link)
                elseif occursin("is required but does not seem to be installed", e.msg)
                    Pkg.rm($s_pkg)
                    Pkg.add(url=$link)
                else
                    println("INVALID ERROR")
                    throw(e)
                end
            else
                println("INVALID ERROR")
                throw(e)
            end
        end
    end
end

function _restore_unregistered(Pkgname)
    s_pkg = String(Pkgname)
    if haskey(UNREGISTERED_REPOS, s_pkg)
        link = UNREGISTERED_REPOS[s_pkg]
        return quote
            @restore_unregistered $Pkgname $link
        end
    else
        return :(warn("Pkg "*s_pkg*" not found"))
    end
end


# using OrderedCollections
# ENV["JULIA_PKG_USE_CLI_GIT"] = true
const UNREGISTERED_REPOS = Dict(
    "POSGModels"        => "https://github.com/WhiffleFish/POSGModels.jl",
)

macro restore_all_unregistered()
    expr = quote end # FIXME: there's gotta be a better way to do this lmao
    for (pkg, link) ∈ UNREGISTERED_REPOS
        push!(expr.args, :(@restore_unregistered($pkg, $link)))
    end
    return expr |> esc
end


if abspath(PROGRAM_FILE) == @__FILE__
    @restore_all_unregistered
end
