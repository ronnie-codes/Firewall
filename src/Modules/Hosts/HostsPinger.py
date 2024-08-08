from Hosts import Host
from Shared import CommandRunner
import re

class HostsPinger:
    def __init__(self, command_runner=CommandRunner()):
        self.command_runner = command_runner

    def ping(self, host: Host):
        output = self.command_runner.run(['ping', '-c', '4', ip])
        match = re.search(r'avg = ([\d.]+) ms', output)

        if match:
            return float(match.group(1))
        else:
            return float('inf')

