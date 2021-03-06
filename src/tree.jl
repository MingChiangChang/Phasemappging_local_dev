# TODO Parameter/Criteria for stopping
# 1. Low residual (good stop)
# 2. To many extra peaks (bad stop/killed)
#    Condition: norm(max.(fitted-data)./data) ?
#    Or is there anything better than 2 norm
struct Tree{T, CP<:AbstractVector{T}, DP<:Int}
    nodes::CP
    depth::DP # Store for convenience
end

function Tree(phases::AbstractVector{<:Phase}, depth::Int)
    # Construct tree with certain depth
    nodes = Node[]
	root = Node()
	push!(nodes, root)
    for d in 1:depth
		phase_combs = combinations(phases, d)
		nodes_at_level = get_nodes_at_level(nodes, d-1)
		#println(size(nodes_at_level))
		for phases in phase_combs
			new_node = Node(phases)
			for old_node in nodes_at_level
			    if is_immidiate_child(old_node, new_node)
				    add_child!(old_node, new_node)
				    push!(nodes, new_node)
					break
                end
		    end
		end
    end
	Tree(nodes, depth)
end

Base.size(t::Tree) = size(t.nodes)

function bft(t::Tree)
    # Breadth-first traversal, return an array of
	# Node with the b-f order
	traversal = Node[]
	for i in 1:t.depth
	    for node in t.nodes
            if get_level(node) == i
				push!(traversal, node)
			end
	    end
	end
	traversal
end

function dft(t::Tree)
    # Depth-first traversal, return an array of Node with
	# the D-F order
end

function search!(t::Tree, traversal_func::Function, x::AbstractVector,
	          y::AbstractVector, std_noise::Real, mean::AbstractVector,
			  std::AbstractVector, maxiter=32, regularization::Bool=true,
			  tol::Real=1e-3) # not_tolerable/prunable)
    node_order = traversal_func(t)
	while !isempty(node_order)
	    node = popfirst!(node_order)
        phases = optimize!(node.current_phases, x, y, std_noise, mean, std,
		                maxiter=maxiter, regularization=regularization)
		if not_tolerable(phases, x, y, tol)
            remove_child!(node_order, node)
		end
    end
end
# subtree
function remove_child!(nv::AbstractVector{<:Node}, parent_node::Node)
    # Given a vector of node and a node, remove
	# all the node that are child of the node
	# TODO Should remove there relationship as well??
	# TODO Will GC take care?
	to_be_removed = Int[]
    for (idx, node) in enumerate(nv)
		if is_child(parent_node, node) && parent_node != node
			push!(to_be_removed, idx)
		end
	end
	deleteat!(nv, to_be_removed)
end

function not_tolerable(phases::AbstractVector{<:Phase},
	                   x::AbstractVector, y::AbstractVector, tol::Real)
	# Only count extra peaks that showed up in reconstruction
    recon = zeros(size(x))
	for phase in phases
		recon += (phase).(x)
	end
	residual = norm(max.(recon-y, 0))
	return residual > tol
end
