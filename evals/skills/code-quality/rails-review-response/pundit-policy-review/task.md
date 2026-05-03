# Respond to Code Review: Authorization Policy PR

## Problem/Feature Description

You submitted a PR that adds a Pundit authorization policy to the `ProjectsController`. Your tech lead left the following review comments. Your job is to evaluate each comment, respond to it (agree/disagree with reasoning), and implement the changes for items you agree with.

---

**PR:** Add Pundit policy for `ProjectsController`
**Branch:** `feature/projects-pundit-policy`

---

**Review Comment 1 — Severity: Critical**
> `ProjectPolicy#update?` returns `true` for any authenticated user. This means any user can edit any project. The policy should check that the current user is the project owner OR a team admin.

**Review Comment 2 — Severity: Suggestion**
> `ProjectPolicy#destroy?` has identical logic to `update?`. Consider extracting a private method `owner_or_admin?` to avoid duplication.

**Review Comment 3 — Severity: Nitpick**
> The policy class is missing YARD documentation on its public methods.

**Review Comment 4 — Severity: Question**
> Why does `ProjectPolicy::Scope#resolve` not filter by `active: true`? Is that intentional? If so, can you add a comment?

---

The current policy is provided below. Extract it before beginning.

=============== FILE: app/policies/project_policy.rb ===============
# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user.present?
  end

  def destroy?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
=============== END FILE ===============

## Output Specification

Produce:

- `app/policies/project_policy.rb` — The updated policy implementing agreed-upon fixes
- `docs/review_response.md` — A structured response to each comment (Agree/Disagree, reasoning, and what was changed or why not)
