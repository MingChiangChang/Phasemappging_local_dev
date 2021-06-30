using Plots
using DelimitedFiles
using .PhaseMapping: readsticks, Lorentz, Phase
using .PhaseMapping: pmp_path!, get_ids
using Test
using .PhaseMapping: readsticks, Phase, Node, add_child!
using .PhaseMapping: is_immidiate_child, Tree, search, bft

stickpatterns = readsticks("test/sticks.txt")
phases = Phase.(stickpatterns)

path = "/home/mingchiang/Desktop/Data/MnTiO-FeTiO/DuncanModifiedFiles/HandCurated_CIFS_MnTiO3-FeTiO3/"
path = path * "sticks.txt"

sticks = readsticks(path, Float64)

phase_1 = Phase(sticks[1], 1.0, 1.0, profile=Lorentz(), width_init=.1)
phase_2 = Phase(sticks[2], 0.5, 1.0, profile=Lorentz(), width_init=.2)
#println(size(phase_arr))
phases = Phase.(sticks, profile=Lorentz(), width_init=.2)

std_noise = .01
mean_θ = [1., 1., .2]
std_θ  = [3., .01, 1.]

x = LinRange(8, 45, 1024)
y = phase_1.(x)+phase_2.(x)

a = Tree(phases[1:5], 3)

println(size(a.nodes))
search(a, bft, x, y, std_noise, mean_θ, std_θ)
