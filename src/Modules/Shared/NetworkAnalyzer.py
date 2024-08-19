from CommandRunner import CommandRunner
import re

class NetworkAnalyzer:
    def __init__(self, command_runner=CommandRunner()):
        self.command_runner = command_runner

    def ping(self, ip: str):
        output = self.command_runner.run(['ping', '-c', '4', ip])
        match = re.search(r'avg = ([\d.]+) ms', output)

        if match:
            return float(match.group(1))
        else:
            return float('inf')

    def traceroute(self, ip: str, timeout: int = 300) -> int:
        """Runs traceroute to a given IP and returns the number of hops to the destination."""
        try:
            output = self.command_runner.run(['./traceroute', '-nI', ip], timeout)
            # Count the number of lines to determine the number of hops
            hops = len(output.splitlines())
            return hops
        except Exception as e:
            print(f"Error running traceroute for {ip}: {e}")
            return float('inf')