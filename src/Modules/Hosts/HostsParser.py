from typing_extensions import List, Optional
from Hosts import Host, Hosts

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
        return len(terms) == 2 and terms[0] != '127.0.0.1' and terms[0] != '255.255.255.255'