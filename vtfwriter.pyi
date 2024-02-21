from types import TracebackType
from typing import Optional

from numpy import ndarray
from typing_extensions import Self

class Block:
    def __enter__(self) -> Self: ...
    def __exit__(
        self,
        exc_type: Optional[type[BaseException]],
        exc_val: Optional[BaseException],
        exc_tb: Optional[TracebackType],
    ) -> None: ...

class ResultBlock(Block):
    def SetResults(self, results: ndarray) -> None: ...
    def BindBlock(self, block: Block) -> None: ...

class File:
    def __init__(self, filename: str, mode: str) -> None: ...
    def __enter__(self) -> Self: ...
    def __exit__(
        self,
        exc_type: Optional[type[BaseException]],
        exc_val: Optional[BaseException],
        exc_tb: Optional[TracebackType],
    ) -> None: ...
    def GeometryBlock(self) -> GeometryBlock: ...
    def StateInfoBlock(self) -> StateInfoBlock: ...
    def NodeBlock(self) -> NodeBlock: ...
    def ElementBlock(self) -> ElementBlock: ...
    def ResultBlock(self, vector: bool = ..., cells: bool = ...) -> ResultBlock: ...
    def ScalarBlock(self) -> ScalarBlock: ...
    def VectorBlock(self) -> VectorBlock: ...
    def DisplacementBlock(self) -> DisplacementBlock: ...

class StateInfoBlock(Block):
    def SetStepData(self, step: int, name: str, time: float) -> None: ...
    def SetModeData(self, step: int, mode: str, time: float) -> None: ...

class GeometryBlock(Block):
    def BindElementBlocks(self, *blocks: ElementBlock, step: Optional[int] = ...) -> None: ...

class NodeBlock(Block):
    def SetNodes(self, nodes: ndarray) -> None: ...

class ElementBlock(Block):
    def AddElements(self, elemetns: ndarray, dim: int) -> None: ...
    def SetPartName(self, name: str) -> None: ...
    def BindNodeBlock(self, block: NodeBlock, partid: Optional[int] = ...) -> None: ...

class ScalarBlock(Block):
    def SetName(self, name: str) -> None: ...
    def BindResultBlocks(self, step: int, *blocks: ResultBlock): ...

class VectorBlock(Block):
    def SetName(self, name: str) -> None: ...
    def BindResultBlocks(self, step: int, *blocks: ResultBlock): ...

class DisplacementBlock(Block):
    def SetName(self, name: str) -> None: ...
    def BindResultBlocks(self, step: int, *blocks: ResultBlock): ...