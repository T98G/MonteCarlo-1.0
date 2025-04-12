from setuptools import setup, Extension
from setuptools.command.build_ext import build_ext as build_ext_orig
from Cython.Build import cythonize
import numpy
import os

# Force use of GCC
os.environ["CC"] = "/opt/homebrew/bin/gcc-14"
os.environ["CXX"] = "/opt/homebrew/bin/g++-14"

ext = Extension(
    "montecarlo_lennard_jones_gas_parallel",
    sources=["montecarlo_lennard_jones_gas_parallel.pyx"],
    include_dirs=[numpy.get_include()],
    extra_compile_args=["-fopenmp"],
    extra_link_args=["-fopenmp"],
)

class build_ext(build_ext_orig):
    def build_extensions(self):
        # Patch all compiler flags added by distutils that are Clang/macOS specific
        # def clean_flags(flags):
        #     return [f for f in flags if not (
        #         f.startswith("-iwithsysroot") or f.startswith("-arch"))]

        def clean_flags(flags):
            return [
                f for f in flags if not (
                    f.startswith("-iwithsysroot") or
                    f.startswith("-arch") or
                    f in ("arm64", "x86_64")
                )
            ]


        c = self.compiler
        if hasattr(c, "compiler_so"):
            c.compiler_so = clean_flags(c.compiler_so)
        if hasattr(c, "linker_so"):
            c.linker_so = clean_flags(c.linker_so)
        if hasattr(c, "compiler"):
            c.compiler = clean_flags(c.compiler)
        if hasattr(c, "compiler_cxx"):
            c.compiler_cxx = clean_flags(c.compiler_cxx)

        super().build_extensions()

setup(
    name="montecarlo_lennard_jones_gas_parallel",
    ext_modules=cythonize([ext], compiler_directives={"language_level": 3}),
    cmdclass={"build_ext": build_ext},
)
