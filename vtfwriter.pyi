from types import TracebackType
from typing import Optional

from numpy import ndarray
from typing_extensions import Self


NODES: int
ELEMENTS: int
GEOMETRY: int
RESULTS: int
SCALAR: int
VECTOR: int
STATEINFO: int
DISPLACEMENT: int

BEAMS: int
QUADS: int
HEXAHEDRONS: int

DIM_SCALAR: int
DIM_VECTOR: int

RESMAP_NODE: int
RESMAP_ELEMENT: int


class File:
    def __init__(self, filename: str, mode: str) -> None: ...
    def __enter__(self) -> Self: ...
    def __exit__(
        self,
        exc_type: Optional[type[BaseException]],
        exc_val: Optional[BaseException],
        exc_tb: Optional[TracebackType],
    ) -> None: ...
    def WriteBlock(self, block: Block) -> None: ...
    def NodeBlock(self) -> NodeBlock: ...
    def ElementBlock(self) -> ElementBlock: ...
    def GeometryBlock(self) -> GeometryBlock: ...
    def ResultBlock(self, vector: bool = ..., cells: bool = ...) -> ResultBlock: ...
    def ScalarBlock(self) -> ScalarBlock: ...
    def VectorBlock(self) -> VectorBlock: ...
    def DisplacementBlock(self) -> DisplacementBlock: ...
    def StateInfoBlock(self) -> StateInfoBlock: ...
    def GetNumBlocks(self) -> int: ...
    def GetBlock(self, blockidx: int) -> Block: ...
    def GetNumBlocksByType(self, tp: int) -> int: ...
    def GetBlockByType(self, tp: int, blockidx: int) -> Block: ...
    def GetBlockByID(self, tp: int, blockid: int) -> Block: ...

class Block:
    def __enter__(self) -> Self: ...
    def __exit__(
        self,
        exc_type: Optional[type[BaseException]],
        exc_val: Optional[BaseException],
        exc_tb: Optional[TracebackType],
    ) -> None: ...
    def GetBlockID(self) -> int: ...
    def GetBlockType(self) -> int: ...

class NodeBlock(Block):
    def SetNodes(self, nodes: ndarray) -> None: ...
    def GetNodes(self) -> ndarray: ...

class ElementBlock(Block):
    def BindNodeBlock(self, block: NodeBlock, partid: Optional[int] = ...) -> None: ...
    def SetPartName(self, name: str) -> None: ...
    def AddElements(self, elements: ndarray, dim: int) -> None: ...
    def GetPartID(self) -> int: ...
    def GetPartName(self) -> str: ...
    def GetNodeBlock(self) -> NodeBlock: ...
    def GetNumElementGroups(self) -> int: ...
    def GetElementGroup(self, groupidx: int) -> tuple[int, ndarray]: ...

class GeometryBlock(Block):
    def BindElementBlocks(self, *blocks: ElementBlock, step: Optional[int] = ...) -> None: ...
    def GetNumSteps(self) -> int: ...
    def GetStepNumber(self, stepidx: int) -> int: ...
    def GetElementBlocks(self, stepidx: int) -> list[ElementBlock]: ...

class ResultBlock(Block):
    def BindBlock(self, block: Block) -> None: ...
    def SetResults(self, results: ndarray) -> None: ...
    def GetDimension(self) -> int: ...
    def GetMapToBlockID(self) -> int: ...
    def GetResultMapping(self) -> int: ...
    def GetResults(self) -> ndarray: ...
    def GetBlock(self) -> Block: ...

class ScalarBlock(Block):
    def SetName(self, name: str) -> None: ...
    def BindResultBlocks(self, step: int, *blocks: ResultBlock): ...
    def GetNumSteps(self) -> int: ...
    def GetStepNumber(self, stepidx: int) -> int: ...
    def GetNumResultBlocks(self, stepidx: int) -> int: ...
    def GetResultBlocks(self, stepidx: int) -> list[ResultBlock]: ...
    def GetName(self) -> str: ...

class VectorBlock(Block):
    def SetName(self, name: str) -> None: ...
    def BindResultBlocks(self, step: int, *blocks: ResultBlock): ...
    def GetNumSteps(self) -> int: ...
    def GetStepNumber(self, stepidx: int) -> int: ...
    def GetNumResultBlocks(self, stepidx: int) -> int: ...
    def GetResultBlocks(self, stepidx: int) -> list[ResultBlock]: ...
    def GetName(self) -> str: ...

class DisplacementBlock(Block):
    def SetName(self, name: str) -> None: ...
    def BindResultBlocks(self, step: int, *blocks: ResultBlock): ...
    def GetNumSteps(self) -> int: ...
    def GetStepNumber(self, stepidx: int) -> int: ...
    def GetNumResultBlocks(self, stepidx: int) -> int: ...
    def GetResultBlocks(self, stepidx: int) -> list[ResultBlock]: ...
    def GetName(self) -> str: ...

class StateInfoBlock(Block):
    def SetStepData(self, step: int, name: str, time: float) -> None: ...
    def SetModeData(self, step: int, mode: str, time: float) -> None: ...
    def GetNumStateInfos(self) -> int: ...
    def GetStepName(self, stepnum: int) -> str: ...
    def GetStepRefValue(self, stepnum: int) -> float: ...
    def GetStepRefType(self, stepnum: int) -> int: ...
