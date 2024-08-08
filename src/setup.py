from setuptools import setup
from setuptools.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension(
        "HostsService",
        ["HostsService.py"],
        extra_compile_args=["-fPIC", "-Ofast", "-march=native", "-ffast-math"]
    )
]

setup(
    ext_modules=cythonize(
        ext_modules,
        compiler_directives={"language_level": "3"}  # Specify language level explicitly
    ),
)
