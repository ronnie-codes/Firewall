from ipaddress import ip_address, IPv4Address
from typing_extensions import List, Tuple, Dict, Any, Optional, TypeAlias
from enum import Enum
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor, as_completed
from dns import resolver

# TODO: Static memory

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


class HostsParser:
    """Provides methods for parsing a hosts file in memory."""

    def parse(self, lines: List[str]) -> Hosts:
        """Parses lines of a host file and returns hosts model."""
        hosts = Hosts([])
        current_host: Optional[Host] = None

        for line in lines:
            terms = line.split()

            if self._is_valid_remote_host(terms):
                next_hostname = terms[1]
                next_address = terms[0]

                if current_host and current_host.name == next_hostname:
                    current_host.addresses.append(next_address)
                elif current_host:
                    hosts.lines.append((current_host, True))
                    current_host = Host(next_hostname, [next_address])
                else:
                    current_host = Host(next_hostname, [next_address])
            else:
                hosts.lines.append((line, False))

        if current_host:
            hosts.lines.append((current_host, True))

        return hosts

    def stringify(self, hosts: Hosts) -> List[str]:
        """Stringifies a hosts model into a list of host file strings."""
        lines: List[str] = []
        for content, is_remote_host in hosts.lines:
            if is_remote_host:
                host: Host = content
                for address in host.addresses:
                    lines.append(f"{address} {host.name}")
            else:
                lines.append(content)

        return lines

    def _is_valid_remote_host(self, terms: List[str]) -> bool:
        return len(terms) == 2 and self._is_valid_ipv4_address(terms[0]) and terms[0] != '127.0.0.1' and terms[0] != '255.255.255.255'

    def _is_valid_ipv4_address(self, address: str) -> bool:
        try:
            ip = ip_address(address)
            return isinstance(ip, IPv4Address)
        except ValueError:
            return False


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


class HostsResolver:
    """Resolves a hostname to a host model using an upstream dns resolver."""

    def __init__(self, my_resolver: resolver.Resolver = resolver.Resolver()):
        self.my_resolver = my_resolver
        self.my_resolver.cache = None

    def resolve(self, hostname: str) -> Optional[Host]:
        """Resolves a hostname to an IPv4 address."""
        try:
            answers = self.my_resolver.resolve(hostname, 'A')
            addresses: List[str] = [answer.address for answer in answers]
            print(hostname, addresses)
            return Host(hostname, addresses)
        except Exception as e:
            print('error resolving...', e)
            return None


class HostsService:
    """Provides API for managing host files."""

    def __init__(self, manager=HostsManager(), my_resolver=HostsResolver()):
        """Initializes the service."""
        self.manager = manager
        self.my_resolver = my_resolver

    def sync_hosts(self) -> Hosts:
        """Updates IP addresses in a hosts file and returns a change set."""
        my_hosts = self.manager.read()
        print('syncing...')

        # Collect hosts that have to be resolved
        remote_hosts = [(i, line_item) for i, (line_item, is_remote_host) in enumerate(
            my_hosts.lines) if is_remote_host]

        with ThreadPoolExecutor() as executor:
            # Submit resolve tasks for each remote host
            future_to_index = {executor.submit(
                self.my_resolver.resolve, host.name): index for index, host in remote_hosts}

            # Process completed futures
            for future in as_completed(future_to_index):
                index = future_to_index[future]
                try:
                    updated_host = future.result()
                    if updated_host:
                        my_hosts.lines[index] = (updated_host, True)
                except Exception as e:
                    print(
                        f'Exception occurred while resolving host at index {index}: {e}')

        self.manager.write(my_hosts)
        return my_hosts


@dataclass
class PacketFilterTable:
    """Represents a host and its addresses"""
    hostname: str
    addresses: List[str]


PacketFilterAlias: TypeAlias = Tuple[str, str]

@dataclass
class PacketFilterConf:
    """Represents a host file and its lines"""
    class LineType(Enum):
        """Represents a packet filter conf line"""
        ALIAS = 0
        TABLE = 1
        OTHER = 2

    lines: List[Tuple[Any, LineType]]


class PacketFilterParser:
    """Parses lines of a host file and returns hosts model."""

    def parse(self, lines: List[str]) -> PacketFilterConf:
        """Parses lines of a host file and returns hosts model."""
        pf_conf = PacketFilterConf([])

        for line in lines:
            terms = line.split()

            if self._is_table(terms):
                next_hostname = terms[1][1:-1]
                next_table = PacketFilterTable(next_hostname, [])
                pf_conf.lines.append((next_table, PacketFilterConf.LineType.TABLE))
            elif self._is_alias(terms):
                alias = terms[0]
                next_hostname = terms[2][1:-1]
                pf_conf.lines.append(((alias, next_hostname), PacketFilterConf.LineType.ALIAS))
            else:
                pf_conf.lines.append((line, PacketFilterConf.LineType.OTHER))

        return pf_conf

    def stringify(self, pf_conf: PacketFilterConf) -> List[str]:
        """Stringifies a hosts model into a list of host file strings."""
        lines: List[str] = []
        for line, line_type in pf_conf.lines:
            if line_type == PacketFilterConf.LineType.TABLE:
                table: PacketFilterTable = line
                updated_addresses = [
                    f"{address}" for address in table.addresses]
                lines.append(
                    f"table <{table.hostname}> {{ {self._format(updated_addresses)} }}")
            elif line_type == PacketFilterConf.LineType.ALIAS:
                alias: PacketFilterAlias = line
                lines.append(f"{alias[0]} = \"{alias[1]}\"")
            else:
                lines.append(line)

        return lines

    def _format(self, addresses: List[str]) -> str:
        return ", ".join(addresses)

    def _is_table(self, terms: List[str]) -> bool:
        return terms and terms[0] == 'table'

    def _is_alias(self, terms: List[str]) -> bool:
        return terms and terms[0].startswith('alias')


class PacketFilterManager:
    """Manages reading and writing operations for host files."""

    def __init__(self, parser: PacketFilterParser = PacketFilterParser()):
        """Initializes the manager with a parser."""
        self.parser = parser

    def read(self, file: str = 'pf.rules') -> PacketFilterConf:
        """Reads from a hosts file"""
        with open(file) as input:
            print('parsing...')
            return self.parser.parse(input.readlines())

    def write(self, pf_conf: PacketFilterConf, file: str = 'pf.rules') -> None:
        """Writes to a hosts file"""
        with open(file, 'w') as output:
            lines = self.parser.stringify(pf_conf)
            for line in lines:
                output.write(f"{line.strip()}\n")


class PacketFilterService:
    """Provides API for managing host files."""

    def __init__(self, manager: PacketFilterManager = PacketFilterManager()):
        """Initializes the service."""
        self.manager = manager

    def update_tables_with_resolver(self, my_resolver: HostsResolver = HostsResolver()):
        """Updates IP addresses in a hosts file and returns a change set."""
        pf_conf = self.manager.read()
        print('syncing...')

        aliases = {}
        for line_item, line_type in pf_conf.lines:
            if line_type == PacketFilterConf.LineType.ALIAS:
                aliases[line_item[0]] = line_item[1]

        for i, _ in enumerate(pf_conf.lines):
            line_item, line_type = pf_conf.lines[i]

            if line_type == PacketFilterConf.LineType.TABLE:
                old_table: PacketFilterTable = line_item

                updated_table = my_resolver.resolve(old_table.hostname if old_table.hostname not in aliases else aliases[old_table.hostname])

                if updated_table and updated_table.addresses:
                    updated_table = PacketFilterTable(old_table.hostname, updated_table.addresses)
                    pf_conf.lines[i] = (updated_table, PacketFilterConf.LineType.TABLE)

        self.manager.write(pf_conf)
        return pf_conf

    def update_tables_with_hosts(self, hosts: Dict):
        """Updates IP addresses in a hosts file and returns a change set."""
        pf_conf = self.manager.read()
        print('syncing...')

        for i, _ in enumerate(pf_conf.lines):
            line_item, is_table = pf_conf.lines[i]

            if is_table:
                old_table: PacketFilterTable = line_item
                updated_table = PacketFilterTable(old_table.hostname, hosts[old_table.hostname] if old_table.hostname in hosts else [])
                pf_conf.lines[i] = (updated_table, is_table)

        self.manager.write(pf_conf)
        return pf_conf

def main():
    """Main"""
    print('running...')
    packet_filter_service = PacketFilterService()
    packet_filter_service.update_tables_with_resolver()
    print('finished...')

if __name__ == "__main__":
    main()