# distutils: language = c++

from libcpp.vector cimport vector

cimport numpy as np
import numpy as np
import ctypes


cdef extern from 'VTFAPI.h':

    cdef const int VTFA_BEAMS
    cdef const int VTFA_QUADS
    cdef const int VTFA_HEXAHEDRONS

    cdef const int VTFA_DIM_SCALAR
    cdef const int VTFA_DIM_VECTOR

    cdef const int VTFA_RESMAP_NODE
    cdef const int VTFA_RESMAP_ELEMENT

    cdef const int VTFA_NODES
    cdef const int VTFA_ELEMENTS
    cdef const int VTFA_GEOMETRY
    cdef const int VTFA_RESULTS
    cdef const int VTFA_SCALAR
    cdef const int VTFA_VECTOR
    cdef const int VTFA_STATEINFO
    cdef const int VTFA_DISPLACEMENT

    cdef cppclass VTFAFile 'VTFAFile':
        VTFAFile()
        int CreateVTFFile(const char*, int, int)
        int OpenVTFFile(const char*)
        int CloseFile()
        int WriteBlock(VTFABlock*)
        int GetNumBlocks()
        VTFABlock* GetBlock(int)
        int GetNumBlocksByType(int)
        VTFABlock* GetBlockByType(int, int)
        VTFABlock* GetBlockByID(int, int)

    cdef cppclass VTFABlock 'VTFABlock':
        int GetBlockID()
        int GetBlockType()

    cdef cppclass VTFANodeBlock 'VTFANodeBlock' (VTFABlock):
        VTFANodeBlock(int, int)
        int SetNodes(const float*, int)
        int GetNumNodes()
        const float* GetNodes()

    cdef cppclass VTFAElementBlock 'VTFAElementBlock' (VTFABlock):
        VTFAElementBlock(int, int, int)
        void SetNodeBlockID(int)
        void SetPartName(const char*)
        void SetPartID(int)
        int AddElements(int, const int*, int)
        int GetNodeBlockID()
        int GetPartID()
        const char* GetPartName()
        int GetNumElementGroups()
        int GetElementGroupInfo(int, int*, int*, int*)
        int GetElementGroup(int, int*, int*)

    cdef cppclass VTFAGeometryBlock 'VTFAGeometryBlock' (VTFABlock):
        VTFAGeometryBlock()
        int AddGeometryElementBlock(int)
        int AddGeometryElementBlock(int, int)
        int GetNumSteps()
        int GetStepNumber(int)
        int GetNumElementBlocks(int)
        int* GetElementBlocks(int)

    cdef cppclass VTFAResultBlock 'VTFAResultBlock' (VTFABlock):
        VTFAResultBlock(int, int, int, int)
        int SetMapToBlockID(int)
        int SetResults1D(const float*, int)
        int SetResults3D(const float*, int)
        int GetDimension()
        int GetResultMapping()
        int GetMapToBlockID()
        int GetNumResults()
        const float* GetResults()

    cdef cppclass VTFAScalarBlock 'VTFAScalarBlock' (VTFABlock):
        VTFAScalarBlock(int)
        void SetName(const char*)
        int AddResultBlock(int, int)
        const char* GetName()
        int GetNumSteps()
        int GetStepNumber(int)
        int GetNumResultBlocks(int)
        const int* GetResultBlocks(int)

    cdef cppclass VTFAVectorBlock 'VTFAVectorBlock' (VTFABlock):
        VTFAVectorBlock(int)
        void SetName(const char*)
        int AddResultBlock(int, int)
        const char* GetName()
        int GetNumSteps()
        int GetStepNumber(int)
        int GetNumResultBlocks(int)
        const int* GetResultBlocks(int)

    cdef cppclass VTFADisplacementBlock 'VTFADisplacementBlock' (VTFABlock):
        VTFADisplacementBlock(int)
        void SetName(const char*)
        void SetRelativeDisplacementResults(int)
        int AddResultBlock(int, int)
        const char* GetName()
        int GetNumSteps()
        int GetStepNumber(int)
        int GetNumResultBlocks(int)
        const int* GetResultBlocks(int)

    cdef cppclass VTFAStateInfoBlock 'VTFAStateInfoBlock' (VTFABlock):
        VTFAStateInfoBlock()
        int SetStepData(int, const char*, float, int)
        int GetNumStateInfos()
        const char* GetStepName(int)
        float GetStepRefValue(int)
        int GetStepRefType(int)


NODES = VTFA_NODES
ELEMENTS = VTFA_ELEMENTS
GEOMETRY = VTFA_GEOMETRY
RESULTS = VTFA_RESULTS
SCALAR = VTFA_SCALAR
VECTOR = VTFA_VECTOR
STATEINFO = VTFA_STATEINFO
DISPLACEMENT = VTFA_DISPLACEMENT

BEAMS = VTFA_BEAMS
QUADS = VTFA_QUADS
HEXAHEDRONS = VTFA_HEXAHEDRONS

DIM_SCALAR = VTFA_DIM_SCALAR
DIM_VECTOR = VTFA_DIM_VECTOR

RESMAP_NODE = VTFA_RESMAP_NODE
RESMAP_ELEMENT = VTFA_RESMAP_ELEMENT


cdef Block _mkblk(VTFABlock* blk):
    blktype = blk.GetBlockType()
    if blktype == VTFA_NODES:
        block = NodeBlock()
    elif blktype == VTFA_ELEMENTS:
        block = ElementBlock()
    elif blktype == VTFA_GEOMETRY:
        block = GeometryBlock()
    elif blktype == VTFA_RESULTS:
        block = ResultBlock()
    elif blktype == VTFA_SCALAR:
        block = ScalarBlock()
    elif blktype == VTFA_VECTOR:
        block = VectorBlock()
    elif blktype == VTFA_STATEINFO:
        block = StateInfoBlock()
    elif blktype == VTFA_DISPLACEMENT:
        block = DisplacementBlock()
    else:
        raise ValueError(f"Unknown block type: {blktype}")
    return block


cdef class File:

    cdef VTFAFile* vtf
    cdef bytes filename
    cdef str mode
    cdef int blockid

    def __init__(self, filename, mode='r'):
        self.filename = filename.encode()
        self.mode = mode
        self.blockid = 1

    def __enter__(self):
        self.vtf = new VTFAFile()
        if 'w' in self.mode:
            self.vtf.CreateVTFFile(self.filename, 'b' in self.mode, 0)
        else:
            self.vtf.OpenVTFFile(self.filename)
        return self

    def __exit__(self, tp, value, backtrace):
        self.vtf.CloseFile()

    def WriteBlock(self, Block block):
        self.vtf.WriteBlock(block._vtf)

    def NodeBlock(self, *args, **kwargs):
        blk = NodeBlock.new(self, self.blockid, *args, **kwargs)
        self.blockid += 1
        return blk

    def ElementBlock(self, *args, **kwargs):
        blk = ElementBlock.new(self, self.blockid, *args, **kwargs)
        self.blockid += 1
        return blk

    def GeometryBlock(self, *args, **kwargs):
        blk = GeometryBlock.new(self, *args, **kwargs)
        return blk

    def ResultBlock(self, *args, **kwargs):
        blk = ResultBlock.new(self, self.blockid, *args, **kwargs)
        self.blockid += 1
        return blk

    def ScalarBlock(self, *args, **kwargs):
        blk = ScalarBlock.new(self, self.blockid, *args, **kwargs)
        self.blockid += 1
        return blk

    def VectorBlock(self, *args, **kwargs):
        blk = VectorBlock.new(self, self.blockid, *args, **kwargs)
        self.blockid += 1
        return blk

    def DisplacementBlock(self, *args, **kwargs):
        blk = DisplacementBlock.new(self, self.blockid, *args, **kwargs)
        self.blockid += 1
        return blk

    def StateInfoBlock(self, *args, **kwargs):
        blk = StateInfoBlock.new(self, *args, **kwargs)
        return blk

    def GetNumBlocks(self):
        return self.vtf.GetNumBlocks()

    def GetBlock(self, int blockidx):
        vtf = self.vtf.GetBlock(blockidx)
        block = _mkblk(vtf)
        block._vtf = vtf
        block.parent = self
        return block

    def GetNumBlocksByType(self, int tp):
        return self.vtf.GetNumBlocksByType(tp)

    def GetBlockByType(self, int tp, int blockidx):
        vtf = self.vtf.GetBlockByType(tp, blockidx)
        block = _mkblk(vtf)
        block._vtf = vtf
        block.parent = self
        return block

    def GetBlockByID(self, int tp, int blockid):
        vtf = self.vtf.GetBlockByID(tp, blockid)
        block = _mkblk(vtf)
        block._vtf = vtf
        block.parent = self
        return block


cdef class Block:

    cdef VTFABlock* _vtf
    cdef File parent

    def __enter__(self):
        return self

    def __exit__(self, type, value, backtrace):
        self.parent.WriteBlock(self)

    def GetBlockID(self):
        return self._vtf.GetBlockID()

    def GetBlockType(self):
        return self._vtf.GetBlockType()


cdef class NodeBlock(Block):

    @staticmethod
    def new(parent, blockid):
        self = NodeBlock()
        self.parent = parent
        self._vtf = new VTFANodeBlock(blockid, 0)
        return self

    cdef VTFANodeBlock* vtf(self):
        return <VTFANodeBlock*> self._vtf

    def SetNodes(self, nodes):
        cdef np.ndarray[float] data = np.ascontiguousarray(nodes, dtype=ctypes.c_float)
        self.vtf().SetNodes(&data[0], len(nodes) // 3)

    def GetNodes(self):
        n = self.vtf().GetNumNodes()
        ptr = self.vtf().GetNodes()
        return np.asarray(<float[:n]> ptr).copy()


cdef class ElementBlock(Block):

    @staticmethod
    def new(parent, blockid):
        self = ElementBlock()
        self.parent = parent
        self._vtf = new VTFAElementBlock(blockid, 0, 0)
        return self

    cdef VTFAElementBlock* vtf(self):
        return <VTFAElementBlock*> self._vtf

    def BindNodeBlock(self, NodeBlock blk, partid=None):
        if partid is None:
            partid = blk.GetBlockID()
        self.vtf().SetNodeBlockID(blk.GetBlockID())
        self.vtf().SetPartID(partid)

    def SetPartName(self, name):
        self.vtf().SetPartName(name.encode())

    def AddElements(self, elements, dim):
        cdef np.ndarray[int] data = np.ascontiguousarray(elements, dtype=ctypes.c_int)
        if dim == 1:
            self.vtf().AddElements(VTFA_BEAMS, &data[0], len(elements) // 2)
        elif dim == 2:
            self.vtf().AddElements(VTFA_QUADS, &data[0], len(elements) // 4)
        else:
            self.vtf().AddElements(VTFA_HEXAHEDRONS, &data[0], len(elements) // 8)

    def GetPartID(self):
        return self.vtf().GetPartID()

    def GetPartName(self):
        return self.vtf().GetPartName()

    def GetNodeBlock(self):
        return self.parent.GetBlockByID(NODES, self.vtf().GetNodeBlockID())

    def GetNumElementGroups(self):
        return self.vtf().GetNumElementGroups()

    def GetElementGroup(self, int groupidx):
        cdef int element_type
        cdef int num_elements
        cdef int num_element_nodes
        self.vtf().GetElementGroupInfo(groupidx, &element_type, &num_elements, &num_element_nodes)
        cdef vector[int] element_ids = vector[int](num_elements)
        cdef vector[int] element_nodes = vector[int](num_element_nodes)
        self.vtf().GetElementGroup(groupidx, &element_nodes[0], &element_ids[0])
        return element_type, np.asarray(<int[:num_element_nodes]> &element_nodes[0]).copy()


cdef class GeometryBlock(Block):

    @staticmethod
    def new(parent):
        self = GeometryBlock()
        self.parent = parent
        self._vtf = new VTFAGeometryBlock()
        return self

    cdef VTFAGeometryBlock* vtf(self):
        return <VTFAGeometryBlock*> self._vtf

    def BindElementBlocks(self, *blocks, step=None):
        if step is None:
            for blk in blocks:
                self.vtf().AddGeometryElementBlock(blk.GetBlockID())
        else:
            for blk in blocks:
                self.vtf().AddGeometryElementBlock(blk.GetBlockID(), step)

    def GetNumSteps(self):
        return self.vtf().GetNumSteps()

    def GetStepNumber(self, int stepidx):
        return self.vtf().GetStepNumber(stepidx)

    def GetElementBlocks(self, int stepidx):
        cdef int n = self.vtf().GetNumElementBlocks(stepidx)
        cdef const int* ptr = self.vtf().GetElementBlocks(stepidx)
        return [self.parent.GetBlockByID(ELEMENTS, ptr[i]) for i in range(n)]


cdef class ResultBlock(Block):

    @staticmethod
    def new(parent, blockid, vector=False, cells=False):
        self = ResultBlock()
        self.parent = parent
        self._vtf = new VTFAResultBlock(
            blockid,
            VTFA_DIM_VECTOR if vector else VTFA_DIM_SCALAR,
            VTFA_RESMAP_ELEMENT if cells else VTFA_RESMAP_NODE,
            0
        )
        return self

    cdef VTFAResultBlock* vtf(self):
        return <VTFAResultBlock*> self._vtf

    def BindBlock(self, blk):
        self.vtf().SetMapToBlockID(blk.GetBlockID())

    def SetResults(self, results):
        cdef np.ndarray[float] data = np.ascontiguousarray(results, dtype=ctypes.c_float)
        if self.GetDimension() == VTFA_DIM_SCALAR:
            self.vtf().SetResults1D(&data[0], len(results))
        elif self.GetDimension() == VTFA_DIM_VECTOR:
            self.vtf().SetResults3D(&data[0], len(results) // 3)

    def GetDimension(self):
        return self.vtf().GetDimension()

    def GetMapToBlockID(self):
        return self.vtf().GetMapToBlockID()

    def GetResultMapping(self):
        return self.vtf().GetResultMapping()

    def GetResults(self):
        cdef int n = self.vtf().GetNumResults()
        cdef const float* ptr = self.vtf().GetResults()
        if self.GetDimension() == VTFA_DIM_SCALAR:
            return np.asarray(<float[:n]> ptr).copy()
        elif self.GetDimension() == VTFA_DIM_VECTOR:
            return np.asarray(<float[:(3*n)]> ptr).copy()

    def GetBlock(self):
        if self.GetResultMapping() == VTFA_RESMAP_ELEMENT:
            return self.parent.GetBlockByID(ELEMENTS, self.GetMapToBlockID())
        elif self.GetResultMapping() == VTFA_RESMAP_NODE:
            return self.parent.GetBlockByID(NODES, self.GetMapToBlockID())


cdef class ScalarBlock(Block):

    @staticmethod
    def new(parent, blockid):
        self = ScalarBlock()
        self.parent = parent
        self._vtf = new VTFAScalarBlock(blockid)
        return self

    cdef VTFAScalarBlock* vtf(self):
        return <VTFAScalarBlock*> self._vtf

    def SetName(self, name):
        self.vtf().SetName(name.encode())

    def BindResultBlocks(self, step, *blocks):
        for blk in blocks:
            self.vtf().AddResultBlock(blk.GetBlockID(), step)

    def GetNumSteps(self):
        return self.vtf().GetNumSteps()

    def GetStepNumber(self, int stepidx):
        return self.vtf().GetStepNumber(stepidx)

    def GetNumResultBlocks(self, int stepidx):
        return self.vtf().GetNumResultBlocks(stepidx)

    def GetResultBlocks(self, int stepidx):
        cdef int n = self.vtf().GetNumResultBlocks(stepidx)
        cdef const int* ptr = self.vtf().GetResultBlocks(stepidx)
        return [self.parent.GetBlockByID(RESULTS, ptr[i]) for i in range(n)]

    def GetName(self):
        return self.vtf().GetName()


cdef class VectorBlock(Block):

    @staticmethod
    def new(parent, blockid):
        self = VectorBlock()
        self.parent = parent
        self._vtf = new VTFAVectorBlock(blockid)
        return self

    cdef VTFAVectorBlock* vtf(self):
        return <VTFAVectorBlock*> self._vtf

    def SetName(self, name):
        self.vtf().SetName(name.encode())

    def BindResultBlocks(self, step, *blocks):
        for blk in blocks:
            self.vtf().AddResultBlock(blk.GetBlockID(), step)

    def GetNumSteps(self):
        return self.vtf().GetNumSteps()

    def GetStepNumber(self, int stepidx):
        return self.vtf().GetStepNumber(stepidx)

    def GetNumResultBlocks(self, int stepidx):
        return self.vtf().GetNumResultBlocks(stepidx)

    def GetResultBlocks(self, int stepidx):
        cdef int n = self.vtf().GetNumResultBlocks(stepidx)
        cdef const int* ptr = self.vtf().GetResultBlocks(stepidx)
        return [self.parent.GetBlockByID(RESULTS, ptr[i]) for i in range(n)]

    def GetName(self):
        return self.vtf().GetName()


cdef class DisplacementBlock(Block):

    @staticmethod
    def new(parent, blockid, relative=True):
        self = DisplacementBlock()
        self.parent = parent
        self._vtf = new VTFADisplacementBlock(blockid)
        self.vtf().SetRelativeDisplacementResults(1 if relative else 0)
        return self

    cdef VTFADisplacementBlock* vtf(self):
        return <VTFADisplacementBlock*> self._vtf

    def SetName(self, name):
        self.vtf().SetName(name.encode())

    def BindResultBlocks(self, step, *blocks):
        for blk in blocks:
            self.vtf().AddResultBlock(blk.GetBlockID(), step)

    def GetNumSteps(self):
        return self.vtf().GetNumSteps()

    def GetStepNumber(self, int stepidx):
        return self.vtf().GetStepNumber(stepidx)

    def GetNumResultBlocks(self, int stepidx):
        return self.vtf().GetNumResultBlocks(stepidx)

    def GetResultBlocks(self, int stepidx):
        cdef int n = self.vtf().GetNumResultBlocks(stepidx)
        cdef const int* ptr = self.vtf().GetResultBlocks(stepidx)
        return [self.parent.GetBlockByID(RESULTS, ptr[i]) for i in range(n)]

    def GetName(self):
        return self.vtf().GetName()


cdef class StateInfoBlock(Block):

    @staticmethod
    def new(parent):
        self = StateInfoBlock()
        self.parent = parent
        self._vtf = new VTFAStateInfoBlock()
        return self

    cdef VTFAStateInfoBlock* vtf(self):
        return <VTFAStateInfoBlock*> self._vtf

    def SetStepData(self, step, name, time):
        self.vtf().SetStepData(step, name.encode(), time, 0)

    def SetModeData(self, mode, name, time):
        self.vtf().SetStepData(mode, name.encode(), time, 1)

    def GetNumStateInfos(self):
        return self.vtf().GetNumStateInfos()

    def GetStepName(self, int stepnum):
        return self.vtf().GetStepName(stepnum)

    def GetStepRefValue(self, int stepnum):
        return self.vtf().GetStepRefValue(stepnum)

    def GetStepRefType(self, int stepnum):
        return self.vtf().GetStepRefType(stepnum)
