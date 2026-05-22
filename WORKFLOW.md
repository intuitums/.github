# getnodus GitHub workflow control plane

This repository is the shared GitHub automation home for the `getnodus` org.
Keep it small. Repo-local workflows should either call a simple reusable
workflow from here or defer to the official GitHub Apps.

## Current shared workflows

Only two reusable workflows are intentionally kept:

- `.github/workflows/typecheck.yml`: lightweight advisory Node checks.
- `.github/workflows/release-please.yml`: release PRs for repos that publish
  versions.

Everything else should be installed or configured at the org/product level, not
rebuilt as custom Actions glue in this repo.

## CI policy

PR CI is advisory by default. It should run fast checks such as `typecheck`,
`lint`, or a small project-specific script. It must not auto-fix, deploy, merge,
or block Fischer from merging.

Full Cloudflare builds should be manual workflow-dispatch checks unless a repo
explicitly needs them on every PR.

## Agent integrations

Codex and Claude should be handled by their official GitHub Apps installed on
the `getnodus` organization.

Manual triggers:

- `@codex review`
- `@codex fix the CI failures`
- `@claude review`

Do not recreate these with `openai/codex-action`, `anthropics/claude-code-action`,
or repo-local `agents.yml` files. Do not enable automatic agent reviews by
default.

## Org ruleset policy

The org ruleset should keep `main` protected from deletion and force pushes.
Default branch protection should not require:

- approving reviews
- CODEOWNERS review
- status checks
- strict up-to-date branches

Checks and AI reviews are advisory. Fischer decides when to merge.

## Removed automation

The previous central automation lanes were intentionally removed:

- custom AI review
- custom Claude responder
- PR hygiene comments
- dependency digest issues
- stale PR sweeps
- failed workflow digests
- reusable security/audit checks
- `.github` repo Dependabot
- central CODEOWNERS

Add any of these back only for a concrete repo-specific need.

## Required org secrets

The small shared workflow lane does not need Codex or Claude secrets.

Keep product/deploy secrets in the repos that need them. Release automation uses
the default GitHub Actions token; do not add a standing org service-account PAT
unless a repo has a concrete release requirement that cannot use GitHub-native
automation.

## Repo onboarding checklist

1. Add a small advisory `ci.yml`.
2. Install/enable official Codex and Claude GitHub Apps at the org level.
3. Add `release.yml` only if the repo publishes versions.
4. Add `deploy.yml` only if the repo deploys production infrastructure.
5. Remove repo-local `agents.yml`, custom AI review, cleanup, stale, dependency
   digest, and mixed-purpose bot workflows.
6. Avoid CODEOWNERS unless there is a real ownership boundary.
7. Add `conductor.json` when a repo should be easy to run from Conductor.
8. Add `.worktreeinclude` only for safe local development files; never broad
   production secret globs.
