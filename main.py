from towers_of_hanoi import utils

number_of_rings = 4

on_facts: list[tuple] = utils.findSolution(number_of_rings)

print("\nExtracted on facts:")
print(on_facts)

utils.generateAnimation(on_facts)
