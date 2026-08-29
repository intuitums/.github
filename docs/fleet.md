# Runner fleet

One physical Linux server (`server-1` in `~/.ssh/config`, OS host `server-1`)
hosts every self-hosted GitHub Actions runner in the org. Runner agents are
concurrency slots, not separate machines: they share 24 threads, 32 GB RAM,
and a 1.8 TB NVMe root volume.

All runners execute as the single Unix account `anvil` (nologin shell,
no sudo, no docker group). One identity to audit, one home to clean.
Repo-scoped access control happens on the GitHub side, not with per-pool
Unix users — an earlier generation of this fleet used `gha-*` per-pool
accounts and drifted into rot; do not resurrect that without a reason you
can write down.

## Layout (on the box)

```
/home/anvil/
├── runners/<name>/          one self-contained dir per runner (install + _work)
├── hooks/job-completed.sh   per-job workspace cleanup (fires via runner .env)
├── cache/                   shared job cache (node-modules, playwright browsers)
└── fleet/bin/               actions-fleet, ci-prune-targets.sh (from runner/ here)
```

System units: `actions.runner.<org-or-repo-slug>.<name>.service`, each with a
`fleet.conf` drop-in (`Slice=actions.slice`, `PrivateTmp=yes`). The slice
caps the whole fleet at 22 of 24 CPUs and 26 of 30 GB so the host can never
be starved. Canonical copies of the slice, both timers, and both oneshot
services live in [`runner/systemd/`](../runner/systemd/).

## Runners

| Name | Custom label | Where it registers |
|---|---|---|
| `intuitum-2vcpu-ubuntu-2604-01/02` | `intuitum-2vcpu-ubuntu-2604` | org, group **Intuitum runners** |
| `intuitum-4vcpu-ubuntu-2604-01/02/03` | `intuitum-4vcpu-ubuntu-2604` | org, group **Intuitum runners** |
| `intuitum-8vcpu-ubuntu-2604-01` | `intuitum-8vcpu-ubuntu-2604` | org, group **Intuitum runners** |
| `intuitum-8vcpu-ubuntu-2604-browser-01` | `intuitum-8vcpu-ubuntu-2604-browser` | org, group **Intuitum runners** |
| `intuitum-24vcpu-ubuntu-2604-01` | same as name | repo `intuitumxyz/e` only |

Naming scheme mirrors Blacksmith's runner tags
(`blacksmith-<n>vcpu-ubuntu-<yymm>`) with the org prefix. The Blacksmith
cloud fleet also registers ephemeral `blacksmith-*` runners on the org —
those are not ours and not on this box.

## Environment

Each runner's `.env` carries: `PATH` (incl. `/home/anvil/.cargo/bin` and the
rootless docker extras), `MAKEFLAGS` and `NODE_OPTIONS` sized to the runner's
tier (2vcpu→-j4/4096, 4vcpu→-j6/6144, 8vcpu→-j8/7680),
`DOCKER_HOST=unix:///run/user/1013/docker.sock`, and the completed-job hook
path. Org runners share `anvil`'s rootless Docker daemon. The host Docker
daemon serves product runtimes — CI never talks to it, and
`actions-fleet clean` only ever prunes the rootless daemon.

`e`'s runner additionally keeps `target/` across runs (`clean: false` in its
workflows); `ci-prune-targets.timer` clears it on the first and third Sunday
at 04:30. It skips runners with jobs in flight and only deletes `target/`
dirs carrying cargo's `CACHEDIR.TAG`.

## Maintenance

```sh
ssh server sudo /home/anvil/fleet/bin/actions-fleet status
ssh server sudo /home/anvil/fleet/bin/actions-fleet restart   # refuses during jobs
ssh server sudo /home/anvil/fleet/bin/actions-fleet clean 14  # caches older than 14d
```

Timers: `ci-fleet-clean.timer` (Sundays 04:00, cache + workspace cleanup),
`ci-prune-targets.timer` (1st/3rd Sunday 04:30, cargo targets). Runners
self-update when idle; verify all units stay on the same version after an
update wave.

The canonical copies of `actions-fleet`, `job-completed.sh`,
`ci-prune-targets.sh`, and the systemd units live in [`runner/`](../runner/)
in this repo. If you change them on the box, change them here in the same
commit — the fleet's docs and scripts drifted through three generations
before, and each time the drift was silent.

## Security notes

- Fork PRs are held for approval (external-contributor gate). Never approve
  an external PR run onto these runners; the box sits on a home LAN.
- `e`'s runner is registered to that repo only, so org jobs cannot land on
  it. Org runners are in a `selected`-visibility group.
- `triage`-style `pull_request_target` workflows stay on GitHub-hosted
  runners, never on this box.
