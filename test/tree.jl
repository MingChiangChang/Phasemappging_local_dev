using Plots
using DelimitedFiles
using Test

using .PhaseMapping: readsticks, Lorentz, Phase
using .PhaseMapping: pmp_path!, get_ids
using .PhaseMapping: readsticks, Phase, Node, add_child!
using .PhaseMapping: is_immidiate_child, Tree, bft, get_level, search!
using .PhaseMapping: get_phase_ids

stickpatterns = readsticks("test/sticks.txt", Float64)
phases = Phase.(stickpatterns)

phase_1 = Phase(stickpatterns[1], 1.0, 1.0, profile=Lorentz(), width_init=.1)
phase_2 = Phase(stickpatterns[2], 0.5, 1.0, profile=Lorentz(), width_init=.2)
phases = Phase.(stickpatterns, profile=Lorentz(), width_init=.2)

std_noise = .01
mean_θ = [1., 1., .2]
std_θ  = [3., .01, 1.]

x = LinRange(8, 45, 1024)
y = phase_1.(x)+phase_2.(x)

# Tests: Tree construction, BFT, removing multiple child

a = Tree(phases[1:5], 3)
@test size(a.nodes)[1]==26
traversal = bft(a)
@testset "bft test" begin
    @test all(n->get_level(n) == 1, traversal[1:5])
    @test [get_level(n) for n in traversal[1:5]] == [1, 1, 1, 1, 1]
    @test [get_level(n) for n in traversal[6:15]] == [2,2,2,2,2,2,2,2,2,2]
    @test [get_level(n) for n in traversal[16:25]] == [3,3,3,3,3,3,3,3,3,3]
end

search!(a, bft, x, y, std_noise, mean_θ, std_θ, 32, true, 1)

println(get_phase_ids(a.nodes[7]))
plot(x, a.nodes[7].current_phases[1].(x)+a.nodes[7].current_phases[2].(x), label="Reconstructed")
plot!(x, y, label="Answer")
