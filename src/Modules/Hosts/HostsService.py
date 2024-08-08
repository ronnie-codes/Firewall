from concurrent.futures import ThreadPoolExecutor, as_completed
from HostsManager import HostsManager
from HostsResolver import HostsResolver
from Hosts import Hosts

class HostsService:
    """Provides API for managing host files."""

    def __init__(self, manager=HostsManager(), resolver=HostsResolver()):
        """Initializes the service."""
        self.manager = manager
        self.resolver = resolver
    
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
                self.resolver.resolve, host.name): index for index, host in remote_hosts}

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
