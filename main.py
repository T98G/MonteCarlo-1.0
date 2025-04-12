#!/usr/bin/env python3
from generate_box import generate_cubic_box
from matplotlib import pyplot as plt
import numpy as np
import platform
import importlib.util
import sys

# Choose the simulation backend dynamically
def try_import(module_name):
    spec = importlib.util.find_spec(module_name)
    if spec is not None:
        return importlib.import_module(module_name)
    return None

sim_module = None
if platform.processor() in ("x86_64", "AMD64", "arm64", "aarch64"):
    sim_module = try_import("montecarlo_lennard_jones_gas_OMP")
if sim_module is None:
    sim_module = try_import("montecarlo_lennard_jones_gas_single_thread")
if sim_module is None:
    sys.exit("Error: No compiled simulation module found. Please run `make` to build one for your system.")

# Simulation parameters
box_length = 80.0
mindist = 4
nparticles = 900
atom_name = "O"
output_file = "test2.pdb"
totalmoves = 3000

box = np.full(3, box_length)
coordinates = generate_cubic_box(nparticles, box_length, mindist).reshape(nparticles, 3)

def write_pdb_trajectory(filename, trajectory, box):
    with open(filename, 'w') as f:
        for frame_idx, coords in enumerate(trajectory):
            nparticles = coords.shape[0]
            atom_name = "H"  # placeholder atom name

            f.write(f"MODEL     {frame_idx + 1:4d}\n")
            f.write("REMARK   Monte Carlo LJ gas trajectory\n")
            f.write(f"CRYST1{box[0]:9.3f}{box[1]:9.3f}{box[2]:9.3f}  90.00  90.00  90.00 P 1           1\n")

            for i in range(nparticles):
                f.write(f"ATOM   {i+1:5d}  {atom_name:2s} RES {i+1:4d}    "
                        f"{coords[i, 0]:8.3f} {coords[i, 1]:8.3f} {coords[i, 2]:8.3f}    "
                        f"1.00  0.00\n")

            f.write("ENDMDL\n")

# Run simulation
results = sim_module.MonteCarloLennardJonesGas(totalmoves, coordinates, box)
pressure = results["pressure"]
traj = results["coordinates"]

# Output
write_pdb_trajectory("traj1.pdb", traj, box)
plt.plot(pressure)
plt.xlabel("Monte Carlo Step")
plt.ylabel("Pressure (reduced units)")
plt.title("Pressure vs Monte Carlo Steps")
plt.grid(True)
plt.show()
