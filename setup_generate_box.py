from setuptools import setup
from Cython.Build import cythonize
import numpy

setup(
    name="generate_cubic_box",
    ext_modules=cythonize("generate_box.pyx", language_level="3"),
    include_dirs=[numpy.get_include()],
)

