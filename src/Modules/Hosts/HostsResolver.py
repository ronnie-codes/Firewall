from Hosts import Host
from typing_extensions import List, Optional
from CommandRunner import CommandRunner
from ipaddress import ip_address, IPv4Address

class HostsResolver:
    """Resolves a hostname to a host model using an upstream dns resolver."""

    def __init__(self, cmd_runner = CommandRunner()):
        self.cmd_runner = cmd_runner

    def resolve(self, hostname: str) -> Optional[Host]:
        """Resolves a hostname to an IPv4 address using nslookup."""
        try:
            output = self.cmd_runner.run(["nslookup", hostname])
            addresses = self._parse_nslookup_output(output)
            print(hostname, addresses)
            return Host(hostname, [addresses[0]] if addresses else [])
        except Exception as e:
            print('error resolving...', e)
            return None

    def _parse_nslookup_output(self, output: str) -> List[str]:
        """Parses the nslookup command output to extract IPv4 addresses."""
        addresses = []
        for line in output.splitlines():
            if "Address: " in line:
                address = line.split("Address: ")[1].strip()
                if self._is_valid_ipv4_address(address):
                    addresses.append(address)
        return addresses

    def _is_valid_ipv4_address(self, address: str) -> bool:
        """Validates if the given string is a valid IPv4 address using ipaddress library."""
        try:
            ip = ip_address(address)
            return isinstance(ip, IPv4Address)
        except ValueError:
            return False