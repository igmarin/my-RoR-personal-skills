FROM ruby:3.4.9-slim

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set up the working directory
WORKDIR /sandbox

# Keep the container running
CMD ["sleep", "infinity"]
