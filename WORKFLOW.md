# getnodus GitHub workflow control plane

This repository is the shared GitHub automation home for the `getnodus` org.
Repo-local workflow files should be thin callers. Shared behavior lives here.

## Lanes

### CI

Repo file: `.github/workflows/ci.yml`

Use for pull request checks only. The default Node path is:

- `getnodus/.github/.github/workflows/typecheck.yml@main`
- `getnodus/.github/.github/workflows/security.yml@main`
- `getnodus/.github/.github/workflows/cleanup.yml@main`
- `getnodus/.github/.github/workflows/ai-review.yml@main`

CI checks install dependencies and report status. They do not push commits,
rewrite lockfiles, format branches, or merge pull requests.

### Agents

Repo file: `.github/workflows/agents.yml`

Use for explicit human-triggered agent work only. `@claude` is the live v1
trigger and routes through `claude-responder.yml`. Do not wire broad scheduled
agent repair loops into repos.

### Release

Repo file: `.github/workflows/release.yml`

Use only for repos that publish versions and have both:

- `release-please-config.json`
- `.release-please-manifest.json`

Release PRs are authored with `NODUS_BOT_PAT` so the release PR can run normal
CI. Product repos that deploy from Cloudflare Builds usually do not need
release-please unless they intentionally publish packages.

### Deploy

Repo file: `.github/workflows/deploy.yml`

Use only for production deployment or production health checks. Keep deploy
logic separate from PR checks and agent triggers.

### Org maintenance

Repo file: `.github/workflows/scheduled.yml` in this repository only.

Central org maintenance runs here so every repo does not need its own cron
workflow. Current jobs remind on stale pull requests and maintain a failed
workflow digest issue.

## `nodus-bot` authority

`nodus-bot` is a conservative service account.

Allowed:

- Comment on issues and pull requests.
- Open or update release/dependency/maintenance PRs.
- Create or update digest issues.
- Use `NODUS_BOT_PAT` when the default GitHub token cannot trigger required
  downstream workflows.

Not allowed:

- Push directly to `main`.
- Auto-merge pull requests.
- Auto-fix CI by committing to human branches.
- Silently mutate workflow, deploy, secret, migration, auth, billing, or
  security-sensitive paths.

## Branch conventions

- `main`: protected integration and deploy lane.
- `feat/*`, `fix/*`, `chore/*`: human or agent feature branches.
- `dependabot/*`: dependency branches.
- `release-please--*`: release automation branches.

Agents and bots should work on branches, open PRs, and stop. Fischer merges.

## Required org secrets

- `NODUS_BOT_PAT`: service account token for PR comments, release PRs, and
  central org maintenance.
- `CLAUDE_CODE_OAUTH_TOKEN`: Claude Code Action token for explicit `@claude`
  workflows and advisory AI review.
- `SUPABASE_ACCESS_TOKEN`: product deploy workflows that use Supabase.
- `SUPABASE_DB_PASSWORD`: product DB migration deploy workflows.

`OPENAI_API_KEY` is intentionally not part of the v1 shared lane. Add `@codex`
routing only after the org-level secret and policy are deliberately set.

## Repo onboarding checklist

1. Add `ci.yml` for PR checks.
2. Add `agents.yml` for explicit `@claude` triggers.
3. Add `release.yml` only if the repo publishes versions.
4. Add `deploy.yml` only if the repo deploys production infrastructure.
5. Remove old mixed-purpose `nodus-bot.yml` cron/workflow files.
6. Use `secrets: inherit` when calling shared workflows that need org secrets.
