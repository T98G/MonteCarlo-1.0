from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy

ext = Extension(
    "montecarlo_lennard_jones_gas_single_thread",
    sources=["montecarlo_lennard_jones_gas_single_thread.pyx"],
    include_dirs=[numpy.get_include()],
)

setup(
    name="montecarlo_lennard_jones_gas_single_thread",
    ext_modules=cythonize([ext], compiler_directives={"language_level": 3}),
)

