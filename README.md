# Monte Carlo Lennard-Jones Gas Simulation

This is a work in progress.

This repository contains a simple Monte Carlo simulation framework for modeling an ideal gas and a Lennard-Jones gas in a cubic box using periodic boundary conditions. The code is designed for educational and research purposes in statistical mechanics and molecular simulation.

## Features

- Generate a cubic box of non-overlapping particles
- Simulate an ideal gas or a Lennard-Jones gas using the Metropolis algorithm
- OpenMP-enabled parallel computation of pairwise interactions
- Output pressure over time and trajectory files in PDB format
- Visualize pressure as a function of simulation steps

---

## Repository Structure

```
project/
│
├── Main.py
├── Makefile
│
├── generate_box.pyx
├── montecarlo_lennard_jones_gas_parallel.pyx
├── montecarlo_lennard_jones_gas_single_thread.pyx
│
├── setup_openmp_intel.py
├── setup_openmp_arm.py
├── setup_single_thread.py
│
├── traj1.pdb
└── test2.pdb (optional)
```

---

## Installation

### Requirements

- Python 3.7+
- Cython
- NumPy
- Matplotlib
- Tqdm
- OpenMP-enabled C compiler (e.g. GCC or Clang with OpenMP support)

### Build Cython Modules

Use the `Makefile` to compile for your architecture:

```bash
make openmp     # Intel/AMD with OpenMP
make arm        # Apple Silicon (M1/M2) with OpenMP
make single     # Single-threaded fallback
```

To clean all build artifacts:

```bash
make clean
```

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

- Periodic boundary conditions are applied during simulation, but the initial configuration does not enforce PBC.
- The single-threaded version (`montecarlo_lennard_jones_gas_single_thread.pyx`) is provided for platforms lacking OpenMP support.

---

## Example Visualization

Use tools like [VMD](https://www.ks.uiuc.edu/Research/vmd/), [PyMOL](https://pymol.org/), or [Chimera](https://www.cgl.ucsf.edu/chimera/) to visualize `traj1.pdb`.

---

## License

This project is open-source and free to use under the MIT License.

---

## Acknowledgments

This project was inspired by standard examples in computational statistical mechanics and aims to be a stepping stone for more advanced simulation models.
