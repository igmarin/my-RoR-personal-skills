FROM ruby:4.0.4-alpine

LABEL io.modelcontextprotocol.server.name="io.github.igmarin/rails-agent-skills-mcp" \
      org.opencontainers.image.title="Rails Agent Skills MCP" \
      org.opencontainers.image.description="Curated library of AI agent skills for Ruby on Rails via MCP" \
      org.opencontainers.image.source="https://github.com/igmarin/rails-agent-skills" \
      org.opencontainers.image.licenses="MIT" \
      security.hardened="true"

# Create non-root user before installing dependencies
RUN addgroup -g 1000 mcp && adduser -u 1000 -G mcp -D mcp

WORKDIR /app

# Copy only Gemfiles first to leverage Docker cache
COPY --chown=mcp:mcp mcp_server/Gemfile mcp_server/Gemfile.lock ./mcp_server/

# Install build deps, patch vulnerable system gems, bundle install, then clean up
RUN apk add --no-cache --virtual .build-deps build-base && \
    gem update json net-imap --no-document && \
    cd mcp_server && \
    bundle config set --local without 'development test' && \
    bundle install && \
    apk del .build-deps

# Copy the entire repository so skills, docs, and workflows are available to the MCP server
COPY --chown=mcp:mcp . .

# Ensure the server uses the correct Gemfile regardless of the current directory
ENV BUNDLE_GEMFILE=/app/mcp_server/Gemfile

# Switch to non-root user
USER mcp

CMD ["bundle", "exec", "ruby", "mcp_server/server.rb"]
