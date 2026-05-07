FROM ruby:4.0.2-alpine

WORKDIR /app

# Copy only Gemfiles first to leverage Docker cache
COPY mcp_server/Gemfile mcp_server/Gemfile.lock ./mcp_server/

RUN apk add --no-cache build-base && \
    cd mcp_server && \
    bundle config set --local without 'development test' && \
    bundle install

# Copy the entire repository so skills, docs, and workflows are available to the MCP server
COPY . .

# Ensure the server uses the correct Gemfile regardless of the current directory
ENV BUNDLE_GEMFILE=/app/mcp_server/Gemfile

CMD ["bundle", "exec", "ruby", "mcp_server/server.rb"]
