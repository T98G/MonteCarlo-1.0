# Makefile

build:
	python3 setup_omp.py build_ext --inplace

clean:
	rm -rf build *.so *.c *.cpp *.pyc __pycache__ *.pyd *.pyo

