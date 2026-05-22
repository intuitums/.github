# getnodus repo standard

This is the default shape for repositories in the `getnodus` org. Keep repo
automation quiet, advisory, and easy to understand.

## Pull request CI

PR checks should report useful signal without blocking Fischer from merging.
Use one lightweight advisory check for normal PRs.

```yaml
name: CI

on:
  pull_request:
    branches: [main]
    types: [opened, synchronize, reopened, ready_for_review]
  workflow_dispatch:

concurrency:
  group: ci-${{ github.repository }}-${{ github.event.pull_request.number || github.run_id }}
  cancel-in-progress: true

jobs:
  typecheck:
    name: Typecheck (advisory)
    uses: getnodus/.github/.github/workflows/typecheck.yml@main
```

Product repos that need a full Cloudflare production build should expose it as
a manual check, not an automatic PR check:

```yaml
on:
  workflow_dispatch:
    inputs:
      check:
        type: choice
        options: [typecheck, full-cloudflare]
        default: typecheck
```

Run the full check only when Fischer or an agent asks for it.

## Agent integrations

Do not add repo-local `agents.yml` files for Codex or Claude.

Use the official GitHub Apps installed at the org level:

- `@codex review` for a Codex review.
- `@codex fix the CI failures` for Codex task work on a PR.
- `@claude review` for a Claude review.

Keep these integrations manual. Do not enable automatic reviews by default.

## Branch protection

Org rulesets should protect `main` from force pushes and deletion. They should
not require approving reviews, CODEOWNERS review, strict up-to-date branches, or
required status checks by default.

## CODEOWNERS

Do not add CODEOWNERS unless a repo has a real ownership boundary. Default
CODEOWNERS files create review-request noise and should stay out of normal
product repos.

## Release lane

Use the shared `release-please.yml` only for repos that publish versions and
already have:

- `release-please-config.json`
- `.release-please-manifest.json`

Most product repos that deploy from Cloudflare Builds do not need release
automation.

## Dependency lane

Do not add dependency automation by default. Add Dependabot only when the repo
needs scheduled update PRs, and keep it quiet:

- weekly schedule
- grouped patch/minor updates
- low open PR limit
- no automatic major version PRs

## No auto-merge

No shared workflow may auto-merge, push fixes to human branches, deploy, or
silently mutate workflow, auth, billing, migration, secret, or security-sensitive
paths. Bots and agents can comment, review, open PRs, and stop.
