# Rails Engine: Authentication Core

## Problem/Feature Description

Our company is moving to a multi-app architecture. We need to extract our core authentication and user management logic into a **Mountable Rails Engine** called `AuthCore`. This will allow other internal apps to share the same user model and login logic.

Your task is to scaffold and configure this engine following **Rails Engine Author** best practices.

## Requirements

1.  Configure the engine as **Mountable** (namespace isolation).
2.  Set up the `User` model within the `AuthCore` namespace.
3.  Configure engine-specific routes.
4.  Ensure the engine can be tested using a **Dummy App** within the engine's `spec/` directory.
5.  Implement a basic `AuthCore::SessionsController` with a `#create` action.

## Output Specification

Produce the following files/structure:
- `lib/auth_core/engine.rb` (with `isolate_namespace`)
- `app/models/auth_core/user.rb`
- `config/routes.rb` (engine routes)
- `spec/dummy/config/application.rb` (dummy app config)
- `app/controllers/auth_core/sessions_controller.rb`
