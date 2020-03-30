import numpy as np
from os.path import join, dirname
from tempfile import TemporaryDirectory
import vtfwriter as vtf

def write_testfile(filename):
    with vtf.File(filename, 'w') as f:
        with f.NodeBlock() as nodes1:
            nodes1.SetNodes([
                0.0, 0.0, 0.0,
                1.0, 0.0, 0.0,
                2.0, 0.0, 0.0,
                0.0, 1.0, 0.0,
                1.0, 1.0, 0.0,
                2.0, 1.0, 0.0,
            ])

        with f.NodeBlock() as nodes2:
            nodes2.SetNodes([
                0.0, 0.0, 0.0,
                1.0, 0.0, 0.0,
                2.0, 0.0, 0.0,
                0.0, 1.0, 0.0,
                1.0, 1.0, 0.0,
                2.0, 1.0, 0.0,
            ])

        with f.ElementBlock() as elements1:
            elements1.AddElements([0, 1, 4, 3, 1, 2, 5, 4], 2)
            elements1.SetPartName('Patch 1')
            elements1.BindNodeBlock(nodes1)

        with f.ElementBlock() as elements2:
            elements2.AddElements([0, 1, 4, 3, 1, 2, 5, 4], 2)
            elements2.SetPartName('Patch 2')
            elements2.BindNodeBlock(nodes2)

        with f.GeometryBlock() as geometry:
            geometry.BindElementBlocks(elements1, elements2)

        with f.ResultBlock() as result1:
            result1.SetResults([0.0, 1.0, 2.0, 0.0, -1.0, -2.0])
            result1.BindBlock(nodes1)

        with f.ResultBlock() as result2:
            result2.SetResults([5.0, 6.0, 7.0, 5.0, 4.0, 3.0])
            result2.BindBlock(nodes2)

        with f.ScalarBlock() as scalar1:
            scalar1.SetName('Whatever 1')
            scalar1.BindResultBlocks(1, result1)

        with f.ScalarBlock() as scalar2:
            scalar2.SetName('Whatever 2')
            scalar2.BindResultBlocks(1, result2)

        with f.StateInfoBlock() as states:
            states.SetStepData(1, 'Time 0.0', 0.0)


def test_vtf():
    with TemporaryDirectory() as path:
        filename = join(path, 'test.vtf')
        write_testfile(filename)

        with open(filename, 'r') as f:
            lines = f.readlines()[8:]

    with open(join(dirname(__file__), 'reference.vtf')) as f:
        reflines = f.readlines()[8:]

    for l, r in zip(lines, reflines):
        assert l.strip() == r.strip()
