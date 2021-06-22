# Do breadth-first-search
# Recursive?
struct Node{T, CP<:AbstractVector{<:Phase{T}},
	        NP<:AbstractVector{<:Phase{T}},
			AS<:Bool, XT<:AbstractVecOrMat, RT<:AbstractVecOrMat, LT<:Int,
			AT<:AbstractVecOrMat, N, CN<:AbstractVector}

	current_phases::CP
	next_phases::NP
	# patterns::PT
	isactive::AS

	x::XT
	r::RT
    level::LT

    parent_node::N
	child_nodes::CN
	# Parameter for stopping
	# 1. Low residual (good stop)
	# 2. To many extra peaks (bad stop/killed)
	#    Condition: norm(max.(fitted-data)./data) ?
	#    Or is there anything better than 2 norm
	# tol::NS
end

# Constructing root
function Node(phases::AbstractVector{<:Phase}, x::AbstractVector,
	         y::AbstractVector, level::Int)
    current_phases = Array{Phase}[]
	Node(current_phases, phases, x, y, 0, [], )
end


function fit!(node::Node)
	#

end
