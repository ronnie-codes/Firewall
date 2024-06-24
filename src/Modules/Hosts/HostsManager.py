from HostsParser import HostsParser
from Hosts import Hosts

class HostsManager:
    """Manages reading and writing operations for host files."""

    def __init__(self, parser: HostsParser = HostsParser()):
        """Initializes the manager with a parser."""
        self.parser = parser

    def read(self, file: str = 'hosts.txt') -> Hosts:
        """Reads from a hosts file"""
        with open(file) as input:
            print('parsing...')
            return self.parser.parse(input.readlines())

    def write(self, hosts: Hosts, file: str = 'hosts.txt') -> None:
        """Writes to a hosts file"""
        with open(file, 'w') as output:
            lines = self.parser.stringify(hosts)
            for line in lines:
                output.write(f"{line.strip()}\n")