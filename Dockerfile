FROM python:3.13-rc-alpine

# Set PYTHONUNBUFFERED to 1 to ensure unbuffered output
ENV PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /usr/src/app

# install dependencies
COPY ./requirements.txt ./
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# start the server
CMD ["python", "main.py"]