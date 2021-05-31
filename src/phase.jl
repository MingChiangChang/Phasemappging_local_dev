struct Phase{T, V<:AbstractVector{T}, CT, A, AT, ST, P}
    # per peak parameters
    c::V # peak intensity
    μ::V # peak location
    id::Int

    dc::CT # peak intensity variation

    # per spectrogram parameters
    a::A # activation
    α::AT # multiplicative shift
	# a, b, c # unit cell dimensions
	# α, β, γ # angles
    σ::ST # peak width

    # peak profile
    profile::P
end

# constructor for single spectrogram analysis
function Phase(c, μ, id::Int; profile = Lorentz(), width_init::Real = 1.)
	length(c) == length(μ) || throw(DimensionMismatch())
	c, μ = promote(c, μ)
	dc = zero(c)
	T = eltype(c)
	a, α, σ = zeros(T), one(T), convert(T, width_init)
    Phase(c, μ, id, dc, a, α, σ, profile)
end

#Backdoor
function Phase(c, μ, id::Int, a::Real, α::Real, σ::Real; profile = Lorentz(), width_init::Real = 1.)
	length(c) == length(μ) || throw(DimensionMismatch())
	c, μ = promote(c, μ)
	dc = zero(c)
	T = eltype(c)
	a, α, σ = a, α, σ
    Phase(c, μ, id, dc, a, α, σ, profile)
end

# n is the number of spectrograms in the data
function Phase(c, μ, id::Int, n::Int; profile = Lorentz(), width_init::Real = 1.)
    length(c) == length(μ) || throw(DimensionMismatch())
    c, μ = promote(c, μ)
    dc = zero(c)
	T = eltype(c)
	a, α, σ = ones(T, n), ones(T, n), fill(convert(T, width_init), n)
    Phase(c, μ, id, dc, a, α, σ, profile)
end

function Phase(S::StickPattern, n::Int; profile = Lorentz(), width_init::Real = 1.)
    Phase(S.c, S.μ, S.id, n, profile = profile, width_init = width_init)
end
function Phase(S::StickPattern; profile = Lorentz(), width_init::Real = 1.)
    Phase(S.c, S.μ, S.id, profile = profile, width_init = width_init)
end
function Phase(S::StickPattern, a::Float64, α::Float64; profile = Lorentz(), width_init::Real = 1.)
    Phase(S.c, S.μ, S.id, a, α, width_init, profile = profile)
end

function active_indices(phases::AbstractVector{<:Phase}, i::Int, tol::Real)
	[p.a[i] > tol for p in phases]
end

# function Phase(P::Phase, θ::AbstractVector)
# 	a, α, σ = θ
# 	Phase(P.c, P.μ, P.id, dc = P.dc, a = a, α = α, σ = σ, profile = P.profile)
# end

# allows copying Phase object and only changing certain parameters
function Phase(P::Phase; dc = P.dc, a = P.a, α = P.α, σ = P.σ, profile = P.profile)
    length(a) == length(α) == length(σ) || throw(DimensionMismatch())
	length(P.c) == length(dc) || throw(DimensionMismatch())
	all(≥(0), a) || throw(DomainError("$a: a has to be non-negative"))
	all(≥(0), α) || throw(DomainError("$α: α has to be non-negative"))
	all(≥(0), σ) || throw(DomainError("$σ: σ has to be non-negative"))
    Phase(P.c, P.μ, P.id, dc, a, α, σ, profile)
end

# evaluate phase at x at jth spectrogram
# to evaluate all spectrograms, use broadcasting
# to P.((x,), (1:length(P.a))') for scalar x or
# P.(x, (1:length(P.a))') for vector x
# TODO: @avx?
function (P::Phase)(x::Real, j::Int)
    y = zero(x)
    @simd for i in eachindex(P.c)
        @inbounds begin
			c = P.c[i] + P.dc[i]
			μ = P.α[j] * P.μ[i]
			y += c * P.profile((x-μ)/P.σ[j])
        end
    end
    P.a[j] * y
end

function (P::Phase)(x::Real)
	y = zero(P.a)
	if y isa Real
		y = P(x, 1)
	else
		for i in eachindex(y)
			y[i] = P(x, i)
		end
	end
	return y
end

################################################################################
# not counting c and μ which are assumed fixed
nparameters(P::Phase) = 3length(P.a) + length(P.dc)
function local_phase(P::Phase, i::Int)
	Phase(P, a = P.a[i], α = P.α[i], σ = P.σ[i]) # @views ?
end
# create view of original arrays when indexing with vector
function local_phase(P::Phase, i::AbstractVector)
	@views Phase(P, a = P.a[i], α = P.α[i], σ = P.σ[i])
end
get_parameters(P::Phase, i::Int) = (P.a[i], P.α[i], P.σ[i])
get_parameters(P::Phase) = vcat(P.a, P.α, P.σ)

function get_parameters!(θ::AbstractVector, P::Phase)
	n = check_div3(length(θ))
	n == length(P.a) || throw(DimensionMismatch())
	θ[1:n] = P.a
	θ[n+1:2n] = P.α
	θ[2n+1:3n] = P.σ
	return θ
end

# creates views of subvectors of θ corresponding to a, α, σ
# if θ does not contain dc
function view_aασ(θ::AbstractVector)
	n = check_div3(length(θ))
	a = @view θ[1:n]
	α = @view θ[n+1:2n]
	σ = @view θ[2n+1:3n]
	return a, α, σ
end

function scale_gradient!(θ::AbstractVector, a_scale = 1., α_scale = 1e-2, σ_scale = 1e-2)
	a, α, σ = view_aασ(θ)
	a .*= a_scale
	α .*= α_scale
	σ .*= σ_scale
	return θ
end

# checks if length of n is divisible by three
function check_div3(n)
	mod(n, 3) == 0 || throw("mod(length(θ)) = $(mod(length(θ), 3)) ≠ 0")
	return n ÷ 3
end

function set_parameters!(P::Phase, θ::AbstractVector)
	n = check_div3(length(θ))
	n == length(P.a) || throw(DimensionMismatch())
	P.a .= θ[1:n]
	P.α .= θ[n+1:2n]
	P.σ .= θ[2n+1:3n]
	return P
end

# only assign ith parameters
function set_parameters!(P::Phase, i::Int, θ::AbstractVector)
	length(θ) == 3 || throw(DimensionMismatch())
	P.a[i] = θ[1]
	P.α[i] = θ[2]
	P.σ[i] = θ[3]
	return P
end
