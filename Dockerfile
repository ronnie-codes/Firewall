FROM python:3.9.19-alpine3.20

# Install dependencies
RUN apk add --no-cache build-base iptables iptables-legacy bash

# Set the environment variable to use the legacy backend
ENV IPTABLES_BACKEND=legacy

# Create project directory and switch to it
WORKDIR /usr/src/app

# Copy source files and requirements
COPY scripts/iptables_legacy.sh .
COPY src/setup.py .
COPY src/main.py .
COPY src/Modules/Shared/CommandRunner.py .
COPY src/Modules/Hosts/Hosts.py .
COPY src/Modules/Hosts/HostsPinger.py .
COPY src/Modules/Hosts/HostsAnalyzer.py .
COPY src/Modules/Hosts/HostsResolver.py .
COPY src/Modules/Hosts/HostsParser.py .
COPY src/Modules/Hosts/HostsManager.py .
COPY src/Modules/Hosts/HostsService.py .
COPY src/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Compile to C
RUN python setup.py build_ext --inplace

# Load tables and run (ensure iptables runs with sufficient privileges)
CMD ["bash", "-c", "./iptables_legacy.sh && python main.py"]
