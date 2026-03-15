import argparse

from towers_of_hanoi import utils

parser = argparse.ArgumentParser()
parser.add_argument("--ring_count", type=int)
args = parser.parse_args()

on_facts: list[tuple] = utils.findSolution(args.ring_count)

print("\nExtracted on facts:")
print(on_facts)

utils.generateAnimation(on_facts)
