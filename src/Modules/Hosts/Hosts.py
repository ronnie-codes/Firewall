from dataclasses import dataclass
from typing_extensions import List, Tuple, Any

@dataclass
class Host:
    """Represents a host and its addresses"""
    name: str
    addresses: List[str]


@dataclass
class Hosts:
    """Represents a host file and its lines"""
    lines: List[Tuple[Any, bool]
                ]  # bool indicates when the line represents a remote host