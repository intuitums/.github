# getnodus GitHub workflow control plane

This repository is the shared GitHub automation home for the `getnodus` org.
Repo-local workflow files should be thin callers. Shared behavior lives here.

## Lanes

### CI

Repo file: `.github/workflows/ci.yml`

Use for pull request checks only. The default required lane is one shared check:

- `getnodus/.github/.github/workflows/typecheck.yml@main`

CI installs dependencies and runs one explicit package script. It does not push
commits, rewrite lockfiles, format branches, run agents, deploy, or merge pull
requests.

For Cloudflare product repos, the PR check should run the same build Cloudflare
runs. Use a repo script such as `ci:cloudflare`, and make that script build every
Cloudflare service in the repo.

Security, cleanup, dependency reporting, and AI review are separate advisory
lanes. Do not make them part of the required PR check set unless the repo has a
clear reason.

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
workflow digest issue. Org maintenance may report, comment, and open/update
issues; it must not auto-merge.

## Dependency policy

Dependabot exists to keep dependency work visible, not noisy. Default config:

- weekly schedule, Monday morning America/Chicago
- grouped patch/minor updates
- low open PR limit
- major version updates ignored until intentionally requested

Use `dep-check.yml` for a digest-style snapshot when a repo needs awareness
without PR churn.

## Local model policy

The server-local Ollama model is `qwen2.5-coder:7b`. It fits the RTX 3050 8GB
budget and is good for cheap advisory triage. It is not the reviewer of record
for sensitive or complex changes; explicit Claude/Codex workflows handle those.

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
7. Add `.github/dependabot.yml` only when the repo has dependencies worth
   scheduled update PRs.

See `REPO_STANDARD.md` for copy-paste caller templates.
