FROM ruby:3.3-slim

# Install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -u 1000 sandbox
WORKDIR /sandbox
RUN chown sandbox:sandbox /sandbox

USER sandbox

# Keep the container running for manual docker exec usage
# To run evaluator: docker exec -it <container> bundle exec ruby -e "Evaluator..."
CMD ["sleep", "infinity"]
