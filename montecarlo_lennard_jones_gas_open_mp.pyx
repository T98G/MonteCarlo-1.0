# cython: language_level=3, boundscheck=False, wraparound=False, cdivision=True, nonecheck=False
# cython: openmp=True
import sys
import numpy as np
cimport numpy as cnp
from libc.math cimport fmod, sqrt, exp, rint
from cython.parallel import prange
from libc.stdlib cimport rand
from openmp cimport omp_get_num_threads, omp_get_thread_num
from libc.stdio cimport printf
from tqdm import tqdm

def progressBar(double progress):
	bar_length = 40
	printf("\e[?25l")
	sys.stdout.flush()


cdef double distance(double[:] a, double[:] b, double[:] box) nogil:
	
	cdef double dx, dy, dz

	dx = a[0] - b[0]
	dx = dx - box[0] * rint(dx / box[0])

	dy = a[1] - b[1]
	dy = dy - box[1] * rint(dy / box[1])

	dz = a[2] - b[2]
	dz = dz - box[2] * rint(dz / box[2])

	return sqrt(dx ** 2 + dy ** 2 + dz ** 2)

cdef double LennardJones(double r, double sigma, double epsilon) nogil:

	"""Calculate the Lennard-Jones potential as a function of the distance r between two particles"""

	return 4 * epsilon * ((sigma / r) ** 12 - ((sigma / r) ** 6))

cdef double BoltzmannFactor(double du, float T, double kb = 1.380649e-23):

	return exp(-(du / (kb * T)))


def MonteCarloLennardJonesGas(int totalmoves, cnp.ndarray[cnp.float64_t, ndim=2] system_, cnp.ndarray[cnp.float64_t, ndim=1] box_):

	cdef cnp.float64_t[:, :] system = system_
	cdef cnp.float64_t[:] box = box_

	cdef double kb = 1.380649e-23
	cdef double sigma = 1, epsilon = 1
	cdef int nmoves = 0, N = system.shape[0], nparticle, i, j
	cdef double dx, dy, dz, V, T = 300.0, potential_energy = 0, potential_energy_p, r, du
	cdef double p_accept, pe_sum = 0
	cdef bint accept
	cdef float rcut = 25
	cdef cnp.ndarray[cnp.float64_t, ndim=1] L = np.zeros(len(box), dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] mins = np.zeros(len(box), dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] maxs = np.zeros(len(box), dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] density = np.zeros(totalmoves, dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] pressure = np.zeros(totalmoves, dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=3] traj = np.zeros((totalmoves, N, 3), dtype=np.float64)
	cdef cnp.ndarray[cnp.float64_t, ndim=1] previous = np.zeros((3), dtype=np.float64)

	with tqdm(total=totalmoves) as pbar:
	
		while nmoves < totalmoves:

			dx = np.random.rand()
			dy = np.random.rand()
			dz = np.random.rand()

				
			nparticle = np.random.randint(0, high=len(system))

			previous[0] = system[nparticle, 0]
			previous[1] = system[nparticle, 1]
			previous[2] = system[nparticle, 2]

			system[nparticle, 0] = fmod(system[nparticle, 0] + dx, box[0])
			system[nparticle, 1] = fmod(system[nparticle, 1] + dy, box[1])
			system[nparticle, 2] = fmod(system[nparticle, 2] + dz, box[2])

			potential_energy_p = potential_energy
			potential_energy = 0
			pe_sum = 0

			with nogil:
				for i in prange(N, schedule="dynamic"):
					for j in range(i + 1, system.shape[0]):
						r = distance(system[i], system[j], box)
						if r < rcut:
							pe_sum += LennardJones(r, sigma, epsilon)

			potential_energy = pe_sum

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
			
			#printf("[%.1f%%]\n", nmoves * 100.0 / totalmoves)

			if accept:
				nmoves += 1
				pbar.update(1)


	return {"coordinates": traj, "density": density, "pressure": pressure}













