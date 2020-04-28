=========
VTFWriter
=========

VTFWriter is a Python implementation of the VTFExpress API used for
writing VTF files, a visualization format for GLView_.


Installation
------------

Before installation, ensure that cython_ and numpy_ are installed::

  pip install --user cython numpy


Then, build and install with::

  pip install --user .


If the VTFExpress libraries are not found on your system, this will
naturally fail.

IFEM-to-VT requires Python 3.  It is possible that, on your system,
*pip* refers to Python 2.  In this case, do::

  pip3 install --user .


.. _GLView: https://ceetron.com/ceetron-glview-inova/
