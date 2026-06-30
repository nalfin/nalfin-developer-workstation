# NDW — Nalfin Developer Workstation

> Developer Workstation as Code. Clone, bootstrap, done.

---

## Quick Start (PC Baru)

### 1. Windows — Persiapan Awal

**Install WSL2:**
```powershell
wsl --install
wsl --set-default-version 2
wsl --install -d Ubuntu
```

**Install:**
- [Docker Desktop](https://www.docker.com/products/docker-desktop) → Settings → Resources → WSL Integration → Enable Ubuntu
- [VS Code](https://code.visualstudio.com) → Install extension **WSL** by Microsoft

---

### 2. VS Code — Connect ke WSL

1. Klik icon **><** di pojok kiri bawah VS Code
2. Pilih **Connect to WSL**
3. Terminal → New Terminal (otomatis masuk WSL)
4. Set default terminal: `Ctrl+Shift+P` → "Terminal: Select Default Profile" → pilih "WSL"

---

### 3. WSL — Setup SSH Keys

SSH keys perlu di-restore dari Google Drive sebelum bisa clone repo.

```bash
# Install rclone dulu
curl https://rclone.org/install.sh | sudo bash

# Setup Google Drive
rclone config
```

Setup rclone:
1. `n` → New remote → name: `gdrive`
2. Pilih nomor **Google Drive**
3. Scope: `1` → Auto config: `n`
4. Copy URL ke browser Windows → login Google
5. Paste token ke terminal

Setelah rclone terhubung, restore SSH keys:

```bash
# Buat folder sementara
mkdir -p ~/backup/ndw

# Download SSH backup dari Google Drive
rclone copy gdrive:NDW/ssh/ ~/backup/ndw/ --include "*.zip"

# Lihat file yang tersedia
ls ~/backup/ndw/*.zip

# Extract (masukkan password enkripsi saat diminta)
unzip -P <password> ~/backup/ndw/ssh_*.zip -d /

# Set permission
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 600 ~/.ssh/config
```

Test koneksi:

```bash
ssh -T git@github-nalfin          # GitHub nalfin
ssh -T git@github-evocavedigital  # GitHub evocave
```

---

### 4. WSL — Clone & Setup

```bash
# Clone repository
mkdir -p ~/dev/platform
git clone git@github-nalfin:nalfin/nalfin-developer-workstation.git \
  ~/dev/platform/nalfin-developer-workstation

cd ~/dev/platform/nalfin-developer-workstation

# Install semua tools (Node.js, PHP, Python, zsh, dll)
bash bootstrap/setup

# Install NDW CLI + dotfiles
bash bootstrap/install
source ~/.zshrc
```

---

### 5. Bootstrap Workstation

```bash
ndw bootstrap
```

Ini akan otomatis:
- Buat folder workspace (`~/dev/...`)
- Generate `infra/.env` dari `config/services.yaml`
- Buat databases dari `config/services.yaml`
- Install dotfiles symlinks

---

### 6. Verifikasi & Start

```bash
# Cek environment
ndw doctor

# Start semua services
ndw work start

# Restore database dari Google Drive
ndw restore --cloud
```

---

## Commands

| Command | Description |
|---|---|
| `ndw bootstrap` | Setup workstation dari config |
| `ndw doctor` | Cek environment health |
| `ndw work start` | Start semua services |
| `ndw work stop` | Stop semua services |
| `ndw work status` | Lihat status services |
| `ndw db up` | Start infrastructure |
| `ndw db down` | Stop infrastructure |
| `ndw db status` | Lihat status containers |
| `ndw db logs` | Lihat logs |
| `ndw db shell` | Masuk PostgreSQL shell |
| `ndw db create <name>` | Buat database baru |
| `ndw db list` | List semua databases |
| `ndw backup` | Backup database lokal |
| `ndw backup --cloud` | Backup + upload Google Drive |
| `ndw backup --ssh` | Backup SSH keys ke Google Drive (encrypted) |
| `ndw restore` | Restore dari lokal |
| `ndw restore --cloud` | Restore database dari Google Drive |
| `ndw restore --ssh` | Restore SSH keys dari Google Drive |

---

## Services

| Service | URL |
|---|---|
| PostgreSQL | `localhost:5432` |
| Redis | `localhost:6379` |
| Adminer | http://localhost:8080 |
| Mailpit | http://localhost:8025 |

---

## Configuration

| File | Description |
|---|---|
| `config/workspace.yaml` | Folder struktur workspace |
| `config/services.yaml` | PostgreSQL, Redis, ports, databases |
| `dotfiles/zshrc` | Zsh configuration |
| `dotfiles/gitconfig` | Git configuration |
| `dotfiles/p10k.zsh` | Powerlevel10k theme |

---

## Bootstrap Scripts

| Script | Description |
|---|---|
| `bash bootstrap/setup` | Install semua tools (fresh install) |
| `bash bootstrap/install` | Install NDW CLI + dotfiles |
| `bash bootstrap/upgrade` | Update NDW ke versi terbaru |
| `bash bootstrap/uninstall` | Hapus NDW |

---

## Backup & Restore

### Database

```bash
# Backup harian
ndw backup --cloud

# Restore di PC baru
ndw restore --cloud
```

Backup disimpan di:
- Lokal: `~/backup/ndw/` (5 backup terakhir)
- Cloud: Google Drive `NDW/backups/`

### SSH Keys

```bash
# Backup SSH keys (terenkripsi)
ndw backup --ssh

# Restore SSH keys di PC baru
ndw restore --ssh
```

SSH keys disimpan di:
- Cloud: Google Drive `NDW/ssh/` (terenkripsi dengan password)

> ⚠️ Ingat password enkripsi SSH — tidak bisa dipulihkan jika lupa.

---

## SSH Config

Repo ini menggunakan custom SSH host aliases:

| Alias | Host | Key |
|---|---|---|
| `github-nalfin` | github.com | `~/.ssh/id_ed25519_nalfin` |
| `github-evocavedigital` | github.com | `~/.ssh/id_ed25519_evocavedigital` |
| `evocave` | evocave.com | `~/.ssh/id_rsa_evocave_server` |

Test koneksi:
```bash
ssh -T git@github-nalfin
ssh -T git@github-evocavedigital
```

Clone repo menggunakan alias:
```bash
git clone git@github-nalfin:nalfin/<repo>.git
```

---

## Repository Layout

```
nalfin-developer-workstation/
├── bin/ndw                   # CLI entry point
├── bootstrap/
│   ├── setup                 # Install semua tools
│   ├── install               # Install NDW CLI
│   ├── dotfiles              # Install dotfiles symlinks
│   ├── generate-env          # Generate infra/.env dari config
│   ├── uninstall             # Hapus NDW
│   └── upgrade               # Update NDW
├── cli/
│   ├── app.sh                # Load libs + delegate ke router
│   ├── router.sh             # Command dispatcher
│   ├── commands/             # Satu file per command
│   └── lib/                  # Shared libraries
├── config/
│   ├── workspace.yaml        # Folder struktur
│   └── services.yaml         # Services config
├── dotfiles/
│   ├── zshrc                 # Zsh config
│   ├── gitconfig             # Git config
│   └── p10k.zsh              # Powerlevel10k config
└── infra/
    ├── docker-compose.yml    # Docker services
    └── .env                  # Generated dari services.yaml
```