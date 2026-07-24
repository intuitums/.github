# Intuitum

Shared GitHub defaults and automation for the Intuitum organization.

- `default.json` is the shared Renovate preset: `github>Intuitumxyz/.github`.
- `claude.yml` provides trusted-collaborator Claude automation.
- `actions.yml` is this public repository's GitHub-hosted validation entrypoint.
- `diff-check.yml`, `workflow-lint.yml`, and `secret-scan.yml` are narrow,
  reusable checks for `solo` and `leo`; empty `diffuse` can opt in when it has
  source to check.

Shared workflows are opt-in. Build, test, deployment, and release automation
remain with the repositories they serve.
