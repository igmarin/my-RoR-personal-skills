---
name: rails-security-review
description: Review Ruby on Rails code for common application security risks. Use when assessing authentication, authorization, parameter handling, redirects, file uploads, secrets, background jobs, or Rails security best practices such as XSS, CSRF, SSRF, and injection safety.
---
# Rails Security Review

Use this skill when the task is to review or harden Rails code from a security perspective.

Prioritize exploitable issues over style. Assume any untrusted input can be abused.

## Review Order

1. Check authentication and authorization boundaries.
2. Check parameter handling and sensitive attribute assignment.
3. Check redirects, rendering, and output encoding.
4. Check file handling, network calls, and background job inputs.
5. Check secrets, logging, and operational exposure.

## High-Severity Findings

- missing or bypassable authorization checks
- SQL, shell, YAML, or constantization injection paths
- unsafe redirects or SSRF-capable outbound requests
- file upload handling that trusts filename, content type, or destination blindly
- secrets or tokens stored in code, logs, or unsafe config

## Medium-Severity Findings

- unscoped mass assignment through weak parameter filtering
- user-controlled HTML rendered without clear sanitization
- sensitive data logged in plaintext
- security-relevant behavior hidden in callbacks or background jobs without guardrails
- brittle custom auth logic where framework primitives would be safer

## Review Checklist

- Are permissions enforced on every sensitive action?
- Are untrusted inputs validated before database, filesystem, or network use?
- Are redirects and URLs constrained?
- Are secrets stored and logged safely?
- Are security assumptions explicit and testable?

## Output Style

Write findings first.

For each finding include:

- severity
- attack path or failure mode
- affected file or area
- smallest credible mitigation
