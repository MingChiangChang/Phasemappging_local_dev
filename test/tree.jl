using .PhaseMapping: readsticks, Phase, Node, add_child!
using .PhaseMapping: is_immidiate_child, Tree

stickpatterns = readsticks("test/sticks.txt")
phases = Phase.(stickpatterns)

a = Tree(phases[1:5], 3)

println(size(a.nodes))
