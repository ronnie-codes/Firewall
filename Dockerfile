# Use Debian-based image
FROM python:3.12.3-slim-bullseye

# Install dependencies
RUN apt-get update && apt-get install -y build-essential iptables

WORKDIR /usr/src/app

# Copy source files and requirements
COPY . .

# Install dependencies
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Compile to C
RUN python build.py build_ext --inplace

# Make the iptables script executable
RUN chmod +x iptables.sh

# Load tables and run (ensure iptables runs with sufficient privileges)
CMD ["sh", "-c", "./iptables.sh && python main.py"]
