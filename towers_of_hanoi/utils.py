import clingo
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from matplotlib.patches import Rectangle

#------------------------------------------------------------------------------
def findSolution(number_of_rings: int) -> list[tuple]:
    # find a solution
    m = 1
    while True:

        ctl = clingo.Control(["-c", f"n={number_of_rings}", "-c", f"m={m}"])
        ctl.load("clingo/main.asp")
        ctl.ground([("base", [])])

        model_data = []

        def on_model(model):
            model_data.extend(model.symbols(shown=True))

        result: clingo.SolveResult = ctl.solve(on_model=on_model)

        if result.satisfiable:
            break

        m += 1

    # extract data from solution
    on_facts = [
        (
            atom.arguments[0].number,
            atom.arguments[1].number
            if atom.arguments[1].type == clingo.SymbolType.Number
            else atom.arguments[1].name,
            atom.arguments[2].number,
        )
        for atom in model_data
        if atom.name == "on"
    ]

    return on_facts

#------------------------------------------------------------------------------
def generateAnimation(on_facts: list[tuple]):
    def build_states(on_facts):
        """Return {time: {ring: support}}."""
        states = {}
        for ring, support, time in on_facts:
            states.setdefault(time, {})[ring] = support
        return states

    states = build_states(on_facts)
    times = sorted(states.keys())
    num_rings = max(r for r, _, _ in on_facts)

    # Precompute tower layouts for each frame
    tower_states = {t: build_towers(states[t]) for t in times}

    fig, ax = plt.subplots(figsize=(8, 5))

    tower_x = {"a": 0, "b": 1, "c": 2}
    ring_height = 0.35
    base_y = 0.2
    tower_height = num_rings + 0.8

    def draw_state(time):
        ax.clear()

        towers = tower_states[time]

        # axes/layout
        ax.set_xlim(-0.6, 2.6)
        ax.set_ylim(0, num_rings + 1.2)
        ax.set_xticks([0, 1, 2])
        ax.set_xticklabels(["A", "B", "C"])
        ax.set_yticks([])
        ax.set_title(f"Towers of Hanoi — Time {time}")

        # ground
        ax.hlines(base_y, -0.5, 2.5)

        # posts
        for x in tower_x.values():
            ax.vlines(x, base_y, tower_height)

        # rings
        for tower_name, stack in towers.items():
            x_center = tower_x[tower_name]

            # stack is [largest, ..., smallest]
            for level, ring in enumerate(stack):
                width = 0.25 + 0.18 * ring
                y = base_y + level * ring_height

                rect = Rectangle(
                    (x_center - width / 2, y),
                    width,
                    ring_height * 0.9,
                    ec="black"
                )
                ax.add_patch(rect)
                ax.text(x_center, y + ring_height * 0.45, str(ring),
                        ha="center", va="center", fontsize=10)
                
        ax.set_aspect("auto")

    def update(frame_index):
        time = times[frame_index]
        draw_state(time)

    ani = FuncAnimation(
        fig,
        update,
        frames=len(times),
        interval=700,
        repeat=True
    )

    plt.show()

#------------------------------------------------------------------------------
def build_towers(state):
    """
    Convert a single state {ring: support} into:
    {'a': [largest...smallest], 'b': [...], 'c': [...]}
    """
    towers = {"a": [], "b": [], "c": []}

    for tower_name in towers:
        # find the base ring on this tower
        base = None
        for ring, support in state.items():
            if support == tower_name:
                base = ring
                break

        # walk upward through rings stacked on that base
        current = base
        while current is not None:
            towers[tower_name].append(current)

            next_ring = None
            for ring, support in state.items():
                if support == current:
                    next_ring = ring
                    break

            current = next_ring

    return towers
