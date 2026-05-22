# Agent Instructions

This repository follows Fischer's default agent workflow.

## Source Of Truth

- Canonical project work should live under `server:/srv/delphi/Projects/...` unless this repo says otherwise.
- Mac/mini checkouts, Conductor workspaces, and Samba mounts are workspaces or views, not durable source of truth.
- Read the nearest repo-specific `AGENTS.md` before editing.

## Workflow

- Work on a branch. Do not push directly to `main`.
- Keep changes scoped to the request.
- Search before adding new patterns or dependencies.
- Do not commit secrets, API tokens, local `.env` files, generated caches, or machine-specific paths.
- Use `.context/` for uncommitted handoffs, notes, screenshots, and logs.

## Verification

Run the repo's documented checks before handing work back. If no repo-specific checks exist, at least run the closest typecheck/test/build command available and report anything that could not be verified.

## Deploys And External Changes

Do not deploy, run production migrations, modify DNS/routes, change billing, or move money unless Fischer explicitly asks for that specific action.
