# getnodus repo standard

This is the boring default. Repos should start here and add only the lanes they
actually need.

## Pull request CI

Use one required check for normal PRs. The shared workflow installs dependencies,
runs one package script, skips inert docs/config changes, and never mutates a
branch.

```yaml
name: CI

on:
  pull_request:
    branches: [main]
    types: [opened, synchronize, reopened, ready_for_review, edited]

concurrency:
  group: ci-${{ github.repository }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  check:
    uses: getnodus/.github/.github/workflows/typecheck.yml@main
```

Product repos that deploy with Cloudflare Builds should pass the exact Cloudflare
build script instead of a generic typecheck:

```yaml
jobs:
  check:
    uses: getnodus/.github/.github/workflows/typecheck.yml@main
    with:
      command: ci:cloudflare
```

If one repo contains multiple Cloudflare services, `ci:cloudflare` must build all
of them. That keeps Cloudflare from being the first place a production build is
tested.

## Agent lane

Use `agents.yml` for explicit human requests only. `@claude` is the live trigger
for v1. Do not add scheduled repair loops or broad auto-fix behavior.

## Dependency lane

Dependabot should be quiet by default:

- weekly schedule
- grouped patch/minor updates
- low open PR limit
- no automatic major version PRs

For Node repos, use this shape:

```yaml
version: 2

updates:
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: weekly
      day: monday
      time: "10:00"
      timezone: America/Chicago
    open-pull-requests-limit: 3
    commit-message:
      prefix: chore(deps)
      prefix-development: chore(deps-dev)
    groups:
      production-patch-minor:
        dependency-type: production
        update-types: [patch, minor]
      development-patch-minor:
        dependency-type: development
        update-types: [patch, minor]
    ignore:
      - dependency-name: "*"
        update-types:
          - version-update:semver-major
```

Add a second `directory` entry for nested apps such as `docs/`.

## Local model lane

The server has an RTX 3050 8GB. Use Ollama `qwen2.5-coder:7b` for cheap local
triage, tiny advisory reviews, and quick code classification. Larger local coder
models are not the default because they do not fit the VRAM budget cleanly.

Use explicit Claude/Codex workflows for real implementation, sensitive diffs,
workflow changes, dependency changes, deploys, auth, billing, and migrations.

## No auto-merge

No shared workflow may auto-merge. Bots can comment, review, open issues, and
open PRs. Fischer lands changes.
