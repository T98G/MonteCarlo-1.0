import sys
import numpy as np 
from libc.math cimport sqrt
cimport nump as cnp


def progressBar(double progress):
	""" Prints a progress bar based on progress percentage. """
	bar_length = 40  # Length of the progress bar
	block = int(round(bar_length * progress))  # Compute filled part
	bar = "#" * block + "-" * (bar_length - block)
	sys.stdout.write(f"\r[{bar}] {progress * 100:.1f}%")
	sys.stdout.flush()


def MonteCarloIdealGas(int totalmoves, cnp.ndarray[cnp.float64_t, ndim=2] system, cnp.ndarray[cnp.float64_t, ndim=1] box):

	cdef float kb = 1.380649e-23
	cdef int nmoves, N
	cdef float dx, dy, dz, V, T, density
	cdef cnp.ndarray[cnp.float64_t, ndim=1] L, densities, pressures
	cdef cnp.ndarray[cnp.float64_t, ndim=2] mins, maxs 
	
	L = np.zeros(len(box))
	mins = np.zeros(len(box))
	maxs = np.zeros(len(box))
	densities = np.zeros(totalmoves)
	pressures = np.zeros(totalmoves)

	nmoves = 0

	while nmoves < totalmoves:

		dx, dy, dz = np.random.rand(3)
		nparticle = np.random.randint(0, high=len(system))

		system[nparticle, 0] = (system[nparticle, 0] + dx) % box[0]
		system[nparticle, 1] = (system[nparticle, 1] + dy) % box[1]
		system[nparticle, 2] = (system[nparticle, 2] + dz) % box[2]

		nmoves += 1 #For an ideal gas all moves are accepted

		for i in range(len(box)):

			mins[i] = min(system[:, i])
			maxs[i] = max(system[:, i])

		L = maxs - mins 

		V = np.prod(L)

		N = len(system)

		density = float(N) / V 

		densities[nmoves] = density

		pressures[nmoves] = (N * kb * T) / V



	results = {"density": densities, "pressure": pressures}

	return results






















