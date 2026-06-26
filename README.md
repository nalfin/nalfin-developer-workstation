# NDW — Nalfin Developer Workstation

> Developer workstation as code. Clone, run, done.

## Quick Start

```bash
git clone https://github.com/nalfin/nalfin-developer-workstation.git \
  ~/dev/platform/nalfin-developer-workstation

cd ~/dev/platform/nalfin-developer-workstation
bash bootstrap/install
```

Reload your shell, then verify:

```bash
ndw --help
ndw --version
```

---

## Commands

| Command | Description |
|---|---|
| `ndw doctor` | Check environment health |
| `ndw db` | Manage development databases |
| `ndw work` | Start / stop workspace |
| `ndw backup` | Backup databases |
| `ndw restore` | Restore databases |

---

## Bootstrap

| Script | Description |
|---|---|
| `bash bootstrap/install` | Install NDW |
| `bash bootstrap/uninstall` | Remove NDW |
| `bash bootstrap/upgrade` | Update to latest |
