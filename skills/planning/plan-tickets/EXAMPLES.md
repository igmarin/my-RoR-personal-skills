# Ticket Planning Examples

## Plan → Ticket Draft

**Plan input:** "Add OAuth2 login via Google"

**Resulting ticket:**

```
BE | Add Google OAuth2 callback endpoint

Classification: type=Story, area=backend, execution_order=foundation, dependency_level=unblocked, target_bucket=next-dev-sprint

**Summary:** Implement the Rails OAuth2 callback action that exchanges the Google authorization code for a user token and creates or finds a User by email.

**Background:** Users need Google login. The callback endpoint completes the OAuth flow after Google redirects back to the app.

**Acceptance Criteria:**
- POST /auth/google/callback exchanges code for token
- Creates or finds User by email from Google profile
- Returns signed session on success; error JSON on failure

**Dependencies:** None. Unblocked.

**Technical Notes:** Uses omniauth-google-oauth2. Callback path must match the redirect URI registered in Google Cloud Console.
```

**Create-in-tracker readiness:**
- Output mode: draft-only; no issue has been created.
- Target project/board must be verified before creation.
- Tracker create-metadata endpoint or equivalent field source must confirm required field names.
- Integration path and credentials must be available outside the repo.
- Explicit user approval is required before creation.
- Validate one issue before bulk creation if sprint or workflow behavior is uncertain.
- Do not set status on create; use the project's default initial status.
