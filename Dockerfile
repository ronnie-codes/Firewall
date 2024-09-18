FROM python:3.9.19-alpine3.20

# Install dependencies
RUN apk add build-base bash iptables iptables-legacy bash linux-headers

# Set the ephemeral port range
RUN sysctl -w net.ipv4.ip_local_port_range="60400 60420"

# Create project directory and switch to it
WORKDIR /usr/src/app

# Copy source files and requirements
COPY bin/traceroute-2.1.5.tar.gz .
COPY scripts/iptables_legacy.sh .
COPY src/setup.py .
COPY src/main.py .
COPY src/Modules/Shared/CommandRunner.py .
COPY src/Modules/Shared/NetworkAnalyzer.py .
COPY src/Modules/Hosts/Hosts.py .
COPY src/Modules/Hosts/HostsAnalyzer.py .
COPY src/Modules/Hosts/HostsResolver.py .
COPY src/Modules/Hosts/HostsParser.py .
COPY src/Modules/Hosts/HostsManager.py .
COPY src/Modules/Hosts/HostsService.py .
COPY src/requirements.txt .

# Install dependencies
RUN pip install --upgrade -r requirements.txt

# Compile to C
RUN python setup.py build_ext --inplace

# Extract the tarball
RUN tar -xzf traceroute-2.1.5.tar.gz

# Build and install traceroute
WORKDIR ./traceroute-2.1.5
RUN make
RUN mv ./traceroute/traceroute ../traceroute

# Cleanup
WORKDIR /usr/src/app
RUN rm -rf traceroute-2.1.5 traceroute-2.1.5.tar.gz
RUN chmod 777 ./traceroute

# Load tables and run (ensure iptables runs with sufficient privileges)
CMD ["bash", "-c", "python main.py"]

