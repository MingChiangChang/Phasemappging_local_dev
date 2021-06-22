# TODO Parameter for stopping
# 1. Low residual (good stop)
# 2. To many extra peaks (bad stop/killed)
#    Condition: norm(max.(fitted-data)./data) ?
#    Or is there anything better than 2 norm
struct Tree{T, CP<:AbstractVector{<:Node}, DP<:Int,
	         NS<:Real, PV<:AbstractVector{T}}
    nodes::CP
    depth::DP

    # Prior as global in trees
    noise_std::NS # standard deviation of the noise
	prior_mean::PV # prior mean for a, α, σ
	prior_std::PV # prior std for a, α, σ
end

function Tree(phases::AbstractVector{Phase}, depth::Int, noise_std::Real=.1,
	          prior_mean = [1., 1., .2], prior_std = [3., .1, .5])
    # Construct tree with certain depth
    nodes = Node[]

end


function bft(t::Tree)
    # Breadth-first traversal, return an array of
	# Node with the b-f order
	traversal = Node[]
	for i in 1:t.depth
	    for node in t.nodes
            if node.level == i
				append!(traversal, node)
			end
	    end
	end
	traversal
end

function dft(t::Tree)
    # Depth-first traversal, return an array of Node with
	# the D-F order
end


function search(t::Tree, traversal_func::Function)
    order = traversal_func(t)
	for node in order
        fit!(node)
    end
end

Base.size(t::Tree) = size(t.nodes)
