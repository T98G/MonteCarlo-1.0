# MonteCarlo-1.0

---

# Monte Carlo Lennard-Jones Gas Simulation

This repository contains a simple Monte Carlo simulation framework for modeling an ideal gas and a Lennard-Jones gas in a cubic box using periodic boundary conditions. The code is designed for educational and research purposes in statistical mechanics and molecular simulation.

## Features

- Generate a cubic box of non-overlapping particles
- Simulate an ideal gas or a Lennard-Jones gas using the Metropolis algorithm
- Use OpenMP for parallel computation of pairwise interactions (Lennard-Jones)
- Output pressure over time and trajectory files in PDB format
- Visualize pressure as a function of simulation steps

---

## Repository Structure

- `Main.py`: Main driver script to run the simulation and generate output.
- `generate_box.pyx`: Cython module to generate initial non-overlapping coordinates in a cubic box.
- `montecarlo_lennard_jones_gas_parallel.pyx`: Cython+OpenMP implementation of the Lennard-Jones Monte Carlo simulation.
- `montecarlo_ideal_gas.py`: (Optional) Module for simulating an ideal gas (not used by default).
- `traj1.pdb`: PDB trajectory output (written during execution).
- `test2.pdb`: Optional placeholder for static structure output (commented out).

---

## Installation

### Requirements

- Python 3.7+
- Cython
- NumPy
- Matplotlib
- Tqdm
- OpenMP-enabled C compiler (e.g. GCC)

### Build Cython Modules

```bash
python setup.py build_ext --inplace
```

_You will need a `setup.py` file to compile the Cython modules. If you don’t have one, I can generate it for you._

---

## Usage

Run the simulation with:

```bash
python Main.py
```

This will:

1. Generate 900 non-overlapping particles in a cubic box (length = 80.0 Å)
2. Run 3000 Monte Carlo moves using the Lennard-Jones potential
3. Save the particle trajectories to `traj1.pdb`
4. Plot the pressure over time

---

## Output

- `traj1.pdb`: Multi-frame PDB file of particle coordinates for visualization.
- Pressure plot: Displays the evolution of system pressure across Monte Carlo moves.

---

## Notes

- The Lennard-Jones simulation is conducted at **300 K** with **σ = 1** and **ε = 1** in reduced units.
- The code assumes reduced units unless otherwise adapted.
- Periodic boundary conditions are applied during simulation, but the initial configuration does not consider PBC.

---

## Example Visualization

You can use tools like VMD, PyMOL, or Chimera to visualize the `traj1.pdb` file.

---

## License

This project is open-source and free to use under the MIT License.

---

## Acknowledgments

This project was inspired by standard examples in computational statistical mechanics and aims to be a stepping stone for more advanced simulation models.

