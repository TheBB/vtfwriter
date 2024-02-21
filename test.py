from vtfwriter import *

with File('/home/eivind/repos/siso/tests/testdata/vtf/Annulus.vtf', 'r') as f:
    fields = (
        [f.GetBlockByType(SCALAR, i) for i in range(f.GetNumBlocksByType(SCALAR))] +
        [f.GetBlockByType(VECTOR, i) for i in range(f.GetNumBlocksByType(VECTOR))] +
        [f.GetBlockByType(DISPLACEMENT, i) for i in range(f.GetNumBlocksByType(DISPLACEMENT))]
    )
    state = f.GetBlockByType(STATEINFO, 0)

    for stepid in range(state.GetNumStateInfos()):
        print(f'Step {stepid}')
    # print(blk.GetElementBlocks(0)[0].GetElementGroup(0))
    # print(blk.GetNodeBlock().GetNodes())
    # print(blk.GetPartName())
    # a, b = blk.GetElementGroup(0)
    # print(a)
    # print(b)
    # f.GetBlock(3)
