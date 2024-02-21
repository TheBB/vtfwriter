from setuptools import Extension
from Cython.Build import cythonize
import numpy as np

def pdm_build_update_setup_kwargs(context, setup_kwargs):
    extension = Extension(
        'vtfwriter',
        ['vtfwriter.pyx'],
        libraries=['VTFExpressAPI'],
        library_dirs=['/usr/local/lib', '/usr/local/lib64'],
        include_dirs=[np.get_include()],
        define_macros=[('NPY_NO_DEPRECATED_API', 'NPY_1_7_API_VERSION')],
    )

    setup_kwargs.update(
        ext_modules=cythonize(
            extension,
            compiler_directives={
                'language_level': '3',
            }
        )
    )
