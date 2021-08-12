#include("../src/PhaseMapping.jl")
c_path = "../../../github/Crystallography_based_shifting/"
include(c_path * "src/util.jl")
include(c_path * "src/peak.jl")
include(c_path * "src/crystal.jl")
include(c_path * "src/crystalphase.jl")
include(c_path * "src/optimize.jl")
using Plots
using DelimitedFiles
using PhaseMapping: readsticks, Lorentz, Phase
using PhaseMapping: pmp_path!, Library
using Test

function get_ids(L::Library)
    [p.id for p in L.phases]
end

#path = "/home/mingchiang/Desktop/Data/MnTiO-FeTiO/DuncanModifiedFiles/HandCurated_CIFS_MnTiO3-FeTiO3/"
path = "data/sticks.txt"
cp_path = "../../github/Crystallography_based_shifting/data/sticks.csv"

f = open(cp_path, "r")
s = split(read(f, String), "#\n") # Windows: #\r\n ...
cs = Vector{CrystalPhase}()

pyro = CrystalPhase(String(s[1]))
delta = CrystalPhase(String(s[2]))
push!(cs, pyro)
push!(cs, delta)
x = collect(8:.1:45)
#y =  ( reconstruct!(pyro, [10.2, 0.2, .3], x)
y = reconstruct!(delta, [5.6, 0.3, .1], x)
y /= max(y...)
plt = plot(x, y)
display(plt)
sticks = readsticks(path, Float64)

#phase_1 = Phase(sticks[1], 1.0, 1.0, profile=Lorentz(), width_init=.1)
#phase_2 = Phase(sticks[2], 0.5, 1.0, profile=Lorentz(), width_init=.2)
#println(size(phase_arr))
phases = Phase.(sticks, profile=Lorentz(), width_init=.2)

# x = LinRange(8, 45, 1024)
# y = phase_1.(x)+phase_2.(x)

libraries, residuals = pmp_path!(phases, x, y, 2, max_shift=1)
# ids = get_ids(libraries[2])
# @test 1 in ids
# @test 2 in ids
# @test 0.95<=libraries[2].phases[1].a<=1
# @test 0.45<=libraries[2].phases[2].a<=0.55
plot!(x, libraries[2].phases[1].(x)+libraries[2].phases[2].(x))
