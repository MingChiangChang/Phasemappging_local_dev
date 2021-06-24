# Do breadth-first-search
# Recursive?
struct Node{T, CP<:AbstractVector{<:Phase{T}},
	        NP<:AbstractVector{<:Phase{T}},
			AS<:Bool, XT<:AbstractVecOrMat, RT<:AbstractVecOrMat, LT<:Int,
			AT<:AbstractVecOrMat, N, CN<:AbstractVector}
	current_phases::CP

	#node_id::LT
end

function Node(phases::AbstractVector{<:Phase})
    current_phases = Array{Phase}[]
	Node(current_phases, phases, x, y, 0, 0, [], )
end

function isChild(parent::Node, child::Node)
    issubset([p.id for p in parent.current_phase],
	         [p.id for p in child.current_phase])
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

level(node::Node) = size(node.current_phases)
