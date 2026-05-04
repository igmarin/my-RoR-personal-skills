# Set Up Dev Environment for a Rails API App

## Problem/Feature Description

A new engineer is joining the HealthTrack API team. The project is a Rails 7 API-only application backed by PostgreSQL, using Docker for the database and Redis for Action Cable and Sidekiq. The repo has no onboarding documentation. The engineer's machine has Ruby (via rbenv), Docker, and `git` installed, but nothing else.

Write a developer onboarding guide that allows the new engineer to go from `git clone` to `rails server` in a single session.

The following configuration files are provided. Extract them before beginning.

=============== FILE: .env.example ===============
DATABASE_URL=postgres://postgres:password@localhost:5432/healthtrack_development
REDIS_URL=redis://localhost:6379/0
OPENAI_API_KEY=
SECRET_KEY_BASE=
=============== END FILE ===============

=============== FILE: Gemfile (excerpt) ===============
ruby "3.2.2"
gem "rails", "~> 7.1"
gem "pg", "~> 1.1"
gem "sidekiq", "~> 7.0"
gem "redis", "~> 5.0"
gem "dotenv-rails"
=============== END FILE ===============

=============== FILE: docker-compose.yml ===============
version: "3.9"
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
  redis:
    image: redis:7
    ports:
      - "6379:6379"
=============== END FILE ===============

## Output Specification

Produce:

- `docs/onboarding.md` — The full onboarding guide, covering:
  1. Prerequisites check (Ruby version, Docker)
  2. Cloning and dependencies (`bundle install`)
  3. Environment setup (copying `.env.example`)
  4. Docker startup (`docker-compose up -d`)
  5. Database setup (`rails db:create db:migrate db:seed`)
  6. Running the test suite
  7. Starting the server
  8. Common troubleshooting tips (at least 3)
