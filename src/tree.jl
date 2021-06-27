# TODO Parameter/Criteria for stopping
# 1. Low residual (good stop)
# 2. To many extra peaks (bad stop/killed)
#    Condition: norm(max.(fitted-data)./data) ?
#    Or is there anything better than 2 norm
struct Tree{T, CP<:AbstractVector{T}, DP<:Int}
    nodes::CP
    depth::DP # Store for convenience

    # Prior as global in trees
    # noise_std::NS # standard deviation of the noise
	# prior_mean::PV # prior mean for a, α, σ
	# prior_std::PV # prior std for a, α, σ
end

function Tree(phases::AbstractVector{<:Phase}, depth::Int)
    # Construct tree with certain depth
    nodes = Node[]
	root = Node()
	push!(nodes, root)
	println(nodes, get_level(nodes[1]))
    for d in 1:depth
		println(d)
		phase_combs = combinations(phases, d)
		nodes_at_level = get_nodes_at_level(nodes, d-1)
		#println(size(nodes_at_level))
		for phases in phase_combs
			new_node = Node(phases)
			println([p.id for p in new_node.current_phases])
			for old_node in nodes_at_level
			    print([p.id for p in old_node.current_phases])
			    if is_immidiate_child(old_node, new_node)
				    println("True!!")
				    add_child!(old_node, new_node)
				    push!(nodes, new_node)
					break
                end
		    end
		end
    end
	Tree(nodes, depth)
end

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


function search(t::Tree, traversal_func::Function)
    order = traversal_func(t)
	for node in order
        fit!(node)
    end
end

Base.size(t::Tree) = size(t.nodes)
