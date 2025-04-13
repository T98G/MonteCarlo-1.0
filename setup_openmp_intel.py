from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy
import os

# Optional: force gcc usage
# os.environ["CC"] = "gcc-13"
# os.environ["CXX"] = "g++-13"

ext = Extension(
    "montecarlo_lennard_jones_gas_omp",
    sources=["montecarlo_lennard_jones_gas_open_mp.pyx"],
    include_dirs=[numpy.get_include()],
    extra_compile_args=["-fopenmp"],
    extra_link_args=["-fopenmp"],
)

setup(
    name="montecarlo_lennard_jones_omp",
    ext_modules=cythonize([ext], compiler_directives={"language_level": 3}),
)

