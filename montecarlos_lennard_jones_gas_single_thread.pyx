# cython: language_level=3

import sys
import numpy as np
cimport numpy as cnp
from libc.math cimport fmod, sqrt, exp, rint

def progressBar(double progress):
	""" Prints a progress bar based on progress percentage. """
	bar_length = 40  # Length of the progress bar
	block = int(round(bar_length * progress))  # Compute filled part
	bar = "#" * block + "-" * (bar_length - block)
	sys.stdout.write(f"\r[{bar}] {progress * 100:.1f}%")
	sys.stdout.flush()

cdef double distance(cnp.ndarray[cnp.float64_t, ndim=1] coords1, cnp.ndarray[cnp.float64_t, ndim=1] coords2, cnp.ndarray[cnp.float64_t, ndim=1] box):

	dx = coords1[0] - coords2[0]
	dx = dx - box[0] * rint(dx / box[0])
	dy = coords1[1] - coords2[1]
	dy = dy - box[1] * rint(dy / box[1])
	dz = coords1[2] - coords2[2]
	dz = dz - box[2] * rint(dz / box[2])

	return sqrt(dx ** 2 + dy ** 2 + dz ** 2)

cdef double LennardJones(double r, double sigma, double epsilon):

	"""Calculate the Lennard-Jones potential as a function of the distance r between two particles"""

	return 4 * epsilon * ((sigma / r) ** 12 - ((sigma / r) ** 6))

cdef double BoltzmannFactor(double du, float T, double kb = 1.380649e-23):

	return exp(-(du / (kb * T)))


def MonteCarloLennardJonesGas(int totalmoves, cnp.ndarray[cnp.float64_t, ndim=2] system, cnp.ndarray[cnp.float64_t, ndim=1] box):

	cdef double kb = 1.380649e-23
	cdef double sigma = 1, epsilon = 1
	cdef int nmoves = 0, N = system.shape[0], nparticle, i
	cdef double dx, dy, dz, V, T = 300.0, potential_energy = 0, potential_energy_p, r, du
	cdef double p_accept
	cdef bint accept
	cdef float rcut = 25
	cdef cnp.ndarray[cnp.float64_t, ndim=1] L = np.zeros(len(box), dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] mins = np.zeros(len(box), dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] maxs = np.zeros(len(box), dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] density = np.zeros(totalmoves, dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] pressure = np.zeros(totalmoves, dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=3] traj = np.zeros((totalmoves, N, 3), dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] previous = np.zeros((3), dtype=np.float64)

	while nmoves < totalmoves:

		dx, dy, dz = np.random.rand(3)
			
		nparticle = np.random.randint(0, high=len(system))

		previous[0] = system[nparticle, 0]
		previous[1] = system[nparticle, 1]
		previous[2] = system[nparticle, 2]

		system[nparticle, 0] = fmod(system[nparticle, 0] + dx, box[0])
		system[nparticle, 1] = fmod(system[nparticle, 1] + dy, box[1])
		system[nparticle, 2] = fmod(system[nparticle, 2] + dz, box[2])

		potential_energy_p = potential_energy
		potential_energy = 0

		for i in range(system.shape[0]):

			for j in range(i + 1, system.shape[0]):

				r = distance(system[i, :], system[j, :], box)

				if r < rcut:

					potential_energy += LennardJones(r, sigma, epsilon)


		du = potential_energy - potential_energy_p

		p_accept = min(1, BoltzmannFactor(du, T, kb))

		if p_accept == 1:

			accept = True

		else:

			accept = np.random.normal() < p_accept

		if not accept:

			system[nparticle, 0] = previous[0]
			system[nparticle, 1] = previous[1]
			system[nparticle, 2] = previous[2]


		# Bounding box
		for i in range(len(box)):
			mins[i] = np.min(system[:, i])
			maxs[i] = np.max(system[:, i])

		for i in range(len(box)):
			L[i] = maxs[i] - mins[i]

		V = L[0] * L[1] * L[2]  # Product of box side lengths

		density[nmoves] = N / V
		pressure[nmoves] = (N * kb * T) / V


		for i in range(N):

			traj[nmoves, i, 0] = system[i, 0]
			traj[nmoves, i, 1] = system[i, 1]
			traj[nmoves, i, 2] = system[i, 2]

		progressBar(nmoves / totalmoves)

		nmoves += 1


	return {"coordinates": traj, "density": density, "pressure": pressure}













