from setuptools import setup
from setuptools.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension(
        "lib",
        ["lib.py"],
        extra_compile_args=["-fPIC", "-O3"]
    )
]

setup(
    ext_modules=cythonize(
        ext_modules,
        compiler_directives={"language_level": "3"}  # Specify language level explicitly
    ),
)
