# Do breadth-first-search
# Recursive?
struct Node{T, CP<:AbstractVector{T}, CN<:AbstractVector}
	current_phases::CP
	child_node::CN
end

Node() = Node(Phase[], Node[]) # Root
Node(phases::AbstractVector{<:Phase}) = Node(phases, Node[])

function is_immidiate_child(parent::Node, child::Node)
	println([p.id for p in parent.current_phases], [p.id for p in child.current_phases])
    return (issubset([p.id for p in parent.current_phases],
	         [p.id for p in child.current_phases]) &&
			  (get_level(parent)[1]-get_level(child)[1] == -1))
end

function add_child!(parent::Node, child::Node)
    push!(parent.child_node, child)
end

function fit!(node::Node, x::AbstractVector, y::AbstractVector,
	          std_noise::Real, mean::AbstractVector, std::AbstractVector,
			  maxiter=32, regularization::Bool=true)
    optimized_phases, residuals = fit_phases!(node.current_phases, x, y,
	                                          std_noise, mean, std,
	                                          maxiter=maxiter,
											  regularization=regularization)
	Node(optimized_phases, node.next_phases, x, residuals, node.node_id, node.level,
	     node.parent_node, node.child_nodes)
end

get_level(node::Node) = size(node.current_phases)[1]
get_phase_ids(node::Node) = [p.id for p in node.current_phases]
#Base.:(==)(a::Node, b::Node)

function get_nodes_at_level(nodes::AbstractVector{<:Node}, level::Int)
    return [n for n in nodes if get_level(n)==level]
end
