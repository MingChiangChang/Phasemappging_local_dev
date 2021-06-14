struct Tree{T, CP<:AbstractVector{<:Phase{T}}, DP<:Int,
	         NS<:Real, PV<:AbstractVector{T}}
    nodes::CP
    depth::DP

    # Prior as global in trees
    noise_std::NS # standard deviation of the noise
	prior_mean::PV # prior mean for a, α, σ
	prior_std::PV # prior std for a, α, σ
end

function Tree(depth::Int, noise_std::Real=.1, prior_mean = [1., 1., .2],
	          prior_std = [3., .1, .5])
    # Construct tree with certain depth
end

function bfs(t::Tree, tol)

function dfs!(t::Tree, ...)

Base.size(t::Tree) = size(t.nodes)
