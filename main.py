from ipaddress import ip_address, IPv4Address
from typing import List, Tuple, Dict, Any, Optional
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor, as_completed
from dns import resolver


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
        # self.my_resolver.nameservers = ['8.8.8.8', '8.4.4.8']
        # sets the timeout for each individual query attempt
        self.my_resolver.timeout = 60.0
        # sets the total time allowed for a query, including retries
        self.my_resolver.lifetime = 60.0

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


@dataclass
class PacketFilterConf:
    """Represents a host file and its lines"""
    lines: List[Tuple[Any, bool]
        ]  # bool indicates when the line represents a table


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
                pf_conf.lines.append((next_table, True))
            else:
                pf_conf.lines.append((line, False))

        return pf_conf

    def stringify(self, pf_conf: PacketFilterConf) -> List[str]:
        """Stringifies a hosts model into a list of host file strings."""
        lines: List[str] = []
        for line, is_table in pf_conf.lines:
            if is_table:
                table: PacketFilterTable = line
                updated_addresses = [
                    f"{address}/32" for address in table.addresses]
                lines.append(
                    f"table <{table.hostname}> {{ {self._format(updated_addresses)} }}")
            else:
                lines.append(line)

        return lines

    def _format(self, addresses: List[str]) -> str:
        return ", ".join(addresses)

    def _is_table(self, terms: List[str]) -> bool:
        return terms and terms[0] == 'table'


class PacketFilterManager:
    """Manages reading and writing operations for host files."""

    def __init__(self, parser: PacketFilterParser = PacketFilterParser()):
        """Initializes the manager with a parser."""
        self.parser = parser

    def read(self, file: str = 'pf.conf') -> PacketFilterConf:
        """Reads from a hosts file"""
        with open(file) as input:
            print('parsing...')
            return self.parser.parse(input.readlines())

    def write(self, pf_conf: PacketFilterConf, file: str = 'pf.conf') -> None:
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

    def update_tables(self, with_hosts: Dict):
        """Updates IP addresses in a hosts file and returns a change set."""
        pf_conf = self.manager.read()
        print('syncing...')

        for i, _ in enumerate(pf_conf.lines):
            line_item, is_table = pf_conf.lines[i]

            if is_table:
                old_table: PacketFilterTable = line_item
                updated_table = PacketFilterTable(old_table.hostname, with_hosts[old_table.hostname] if old_table.hostname in with_hosts else [])
                pf_conf.lines[i] = (updated_table, is_table)

        self.manager.write(pf_conf)
        return pf_conf


class HostsMapper:
    """Maps Hosts to other things"""

    def hosts_to_dict(self, for_hosts: Hosts) -> Dict:
        """Maps a host model to a dict"""
        dict_of_hosts = {}
        for content, is_host in for_hosts.lines:
            if is_host:
                dict_of_hosts[content.name] = content.addresses
        return dict_of_hosts


if __name__ == "__main__":
    print('running...')

    hosts_service = HostsService()
    hosts_mapper = HostsMapper()
    packet_filter_service = PacketFilterService()

    hosts = hosts_service.sync_hosts()
    hosts_dict = hosts_mapper.hosts_to_dict(hosts)
    packet_filter_service.update_tables(hosts_dict)

    print('finished...')
