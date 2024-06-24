FROM python:3.9.19-alpine3.20

# Install dependencies
RUN apk add --no-cache build-base iptables iptables-legacy

# Create project directory and switch to it
WORKDIR /usr/src/app

# Copy source files and requirements
COPY scripts/iptables_legacy.sh .
COPY src/setup.py .
COPY src/main.py .
COPY src/Modules/PacketFilter/PacketFilter.py .
COPY src/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Compile to C
RUN python setup.py build_ext --inplace

RUN chmod 777 iptables_legacy.sh

# Load tables and run (ensure iptables runs with sufficient privileges)
CMD ["sh", "-c", "./iptables_legacy.sh && python main.py"]