from concurrent.futures import ThreadPoolExecutor, as_completed
import math
from typing import List
from NetworkAnalyzer import NetworkAnalyzer

class HostsAnalyzer:
    """Answers miscellaneous queries about hosts"""

    def __init__(self, analyzer: NetworkAnalyzer = NetworkAnalyzer()):
        self.analyzer = analyzer

    def find_closest_ip(self, ips: List[str]) -> str:
        """Finds the nearest ip"""
        latencies = {}

        # Use a ThreadPoolExecutor to run pings concurrently
        with ThreadPoolExecutor() as executor:
            futures = {executor.submit(self.analyzer.traceroute, ip): ip for ip in ips}

            # Process completed futures
            for future in as_completed(futures):
                ip = futures[future]
                try:
                    latency = future.result()
                    if not math.isinf(latency):  # Ignore inf values
                        latencies[ip] = latency
                        print(f'Latency for {ip}: {latency} ms')
                    else:
                        print(f'Ping to {ip} failed or timed out (inf latency)')
                except Exception as e:
                    print(f'Error pinging {ip}: {e}')

        if latencies:
            closest_ip = min(latencies, key=latencies.get)
            return closest_ip

        return ips[0]
