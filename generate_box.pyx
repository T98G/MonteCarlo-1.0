import sys
import numpy as np
from libc.math cimport sqrt
cimport numpy as cnp


def progressBar(double progress):
	""" Prints a progress bar based on progress percentage. """
	bar_length = 40  # Length of the progress bar
	block = int(round(bar_length * progress))  # Compute filled part
	bar = "#" * block + "-" * (bar_length - block)
	sys.stdout.write(f"\r[{bar}] {progress * 100:.1f}%")
	sys.stdout.flush()


cdef double simple_distance(cnp.ndarray[cnp.float64_t, ndim=1] coords1, 
                            cnp.ndarray[cnp.float64_t, ndim=1] coords2):

	"""Calculate distance between particles without taking PBC into account. Only suited for generating a cubic box."""

	return sqrt((coords1[0] - coords2[0]) **2 + (coords1[1] - coords2[1]) **2 + (coords1[2] - coords2[2]) **2)


def generate_cubic_box(int nparticles, float boxsize, float mindist):
	
	cdef int i, count 
	cdef float x, y, z
	cdef cnp.ndarray[cnp.float64_t, ndim=2] coordinates = np.zeros((3, nparticles), dtype=np.float64)


	count = 0

	while count < nparticles:

		x, y, z = np.random.rand(3) * boxsize

		valid = True

		for i in range(nparticles):

			if np.all(coordinates[:, i] != 0):

				if simple_distance(np.array([x, y, z]), coordinates[:, i]) < mindist:

					valid = False

					break

		if valid:

			for i in range(nparticles):

				if np.all(coordinates[:, i] == 0):

					coordinates[0, i] = x 
					coordinates[1, i] = y  
					coordinates[2, i] = z 

					count += 1

					break
				
			progressBar(count / nparticles)
	
	return coordinates
