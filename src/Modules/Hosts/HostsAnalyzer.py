from Hosts import Host

class HostsAnalyzer:
    """Answers miscellaneous queries about hosts"""

    def __init__(self, pinger: HostsPinger = HostsPinger()):
        self.pinger = pinger

    def find_closest_ip(self, host: Host) -> str:
		ips = host.addresses
		latencies = {}

		for ip in ips:
			print(f'Pinging {ip}...')
			latency = self.pinger.ping(ip)
			latencies[ip] = latency
			print(f'Latency for {ip}: {latency} ms')

			closest_ip = min(latencies, key=latencies.get)

		return closest_ip
