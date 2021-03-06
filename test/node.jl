using .PhaseMapping: readsticks, Phase, Node, add_child!
using .PhaseMapping: is_immidiate_child

stickpatterns = readsticks("test/sticks.txt")
phases = Phase.(stickpatterns)

root = Node()
node1 = Node([phases[1]], [])
node2 = Node([phases[1] ,phases[2]], [])

add_child!(root, node1)
add_child!(node1, node2)
@test is_immidiate_child(node1, node2)
