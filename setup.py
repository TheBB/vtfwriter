#!/usr/bin/env python

from setuptools import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy as np

extension = Extension(
    'vtfwriter',
    ['vtfwriter.pyx'],
    libraries=['VTFExpressAPI'],
    library_dirs=['/usr/local/lib', '/usr/local/lib64'],
    include_dirs=[np.get_include()],
)

setup(
    name='VTFWriter',
    version='1.0.0',
    description='Python interface to libVTFExpressAPI.',
    maintainer='Eivind Fonn',
    maintainer_email='eivind.fonn@sintef.no',
    ext_modules=cythonize(
        extension,
        compiler_directives={
           'language_level': '3',
        },
    ),
    install_requires=['numpy'],
)
