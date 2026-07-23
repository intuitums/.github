# Intuitumxyz GitHub

Organization defaults and shared automation:

- `default.json` is the Renovate preset `github>Intuitumxyz/.github`.
- `claude.yml` is the reusable trusted-collaborator Claude workflow.
- `shared-checks.yml` provides changed-file hygiene, Actions validation, and
  secret scanning for `solo`, `leo`, and `diffuse` only.

The reusable workflows do not run here or organization-wide. Builds, tests,
deployments, releases, and notifications stay with the repository they serve.
`Intuitumxyz/workflow` remains available only until its live consumers migrate.
