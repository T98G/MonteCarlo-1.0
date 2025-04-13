# Set your default compiler and python
PYTHON=python3
PIP=pip3

# Targets
.PHONY: all clean arm openmp single

all:
	@echo "Choose a target:"
	@echo "  make arm        - Compile for Apple Silicon with OpenMP (M1/M2)"
	@echo "  make openmp     - Compile for Intel/AMD with OpenMP"
	@echo "  make single     - Compile single-threaded version (no OpenMP)"

arm:
	$(PYTHON) setup_generate_box.py build_ext --inplace
	$(PYTHON) setup_openmp_arm.py build_ext --inplace

openmp:
	$(PYTHON) setup_generate_box.py build_ext --inplace
	$(PYTHON) setup_openmp_intel.py build_ext --inplace

single:
	$(PYTHON) setup_generate_box.py build_ext --inplace
	$(PYTHON) setup_single_thread.py build_ext --inplace

clean:
	rm -rf build *.c *.so __pycache__ montecarlo_lennard_jones_gas_parallel.* montecarlo_lennard_jones_gas_single_thread.* generate_cubic_box.*

