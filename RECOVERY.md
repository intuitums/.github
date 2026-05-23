# Recovery: mini unreachable while traveling

If `ssh mini` doesn't respond from `mac`, the mini is in one of a few known states. Work top-down — each step is faster than the next.

## 1. Quick diagnosis

```sh
# Tailscale alive?
tailscale ping mini

# SSH responding?
nc -zv 100.70.110.42 22

# Screen Sharing port open?
nc -zv 100.70.110.42 5900
```

| Tailscale | SSH | Screen Share | Likely state                                  |
| --------- | --- | ------------ | --------------------------------------------- |
| ✓         | ✓   | ✓            | mini up + logged in — should "just work"      |
| ✓         | ✗   | ✓            | mini up but at FileVault unlock — use VNC     |
| ✓         | ✗   | ✗            | mini up but firewall blocking — unusual       |
| ✗         | ✗   | ✗            | mini powered off / network down / Tailscale down |

## 2. Recovery paths (ordered cheapest → most disruptive)

### A. VNC to FileVault unlock screen

```sh
open vnc://100.70.110.42
```

Enter the FileVault password at the macOS unlock screen. User-login agents (`co.fischer.tmux-main`, postgres, etc.) start automatically once unlocked. After ~30s, `ssh mini` works.

### B. Wake-on-LAN (if mini is asleep, not off)

```sh
# From mac (Tailnet-side)
wakeonlan <mini-mac-address>

# Or LAN-side via server
ssh server 'wakeonlan <mini-mac-address>'
```

Fill in MAC address — run `ifconfig en0 | grep ether` on mini next time it's up.

### C. Ask housemate / neighbor

Press power button (if off) and enter FileVault password.

### D. Continue without mini

The server has parallel installs of most server-shaped services:
- All portable MCPs (`github`, `gmail_workspace`, `blueprint_design`, `veyra_social`, `memory`)
- Memory store
- Postgres 18
- gh CLI
- delphi CLI

From mac you can `ssh server` and continue most work. macOS-locked agents (Atlas Control, Edoras Safari, Lazuli Computer) are unavailable until mini returns.

## 3. What still works while mini is down

- `ssh server` — server-side MCPs, git, deploys, delphi commands
- `gh` from mac — GitHub API, PR management, issue triage
- `linear.app/getnodus` via browser
- Conductor (if installed on mac) — can spawn workspaces, though canonical clones live on mini

## 4. Periodic test (quarterly)

Schedule: 1st Saturday of Feb / May / Aug / Nov.

1. From mac, reboot mini: `ssh mini sudo shutdown -r now`
2. Wait for `ssh mini` to fail
3. Execute recovery path A (VNC)
4. Time end-to-end recovery; if > 5 min, investigate
5. Log result in Linear issue (label: `recovery-drill`)

## See also

- `~/CLAUDE.md` on mini — operating guide
- `/home/fischer/CLAUDE.md` on server — server-side ops
- `~/.zshenv` exports on mini — what's available globally in any shell
