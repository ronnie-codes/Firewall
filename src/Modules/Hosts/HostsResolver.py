from Hosts import Host
from typing_extensions import List, Optional
from dns import resolver

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
            return Host(hostname, [addresses[0]] if addresses else [])
        except Exception as e:
            print('error resolving...', e)
            return None
