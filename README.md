# NDW — Nalfin Developer Workstation

> Restore your dev identity (SSH keys + dotfiles) on any new device. Clone, run one script, done.

No WSL, no Docker, no local databases — projects connect straight to Supabase/Upstash.
Works the same way on Windows (Git Bash) and macOS (Terminal).

> ⚠️ **Repo ini public.** Jangan pernah commit SSH keys, `.env`, token, atau credential apa pun ke sini — itu semua tempatnya di `~/.ssh` (backup terenkripsi ke Google Drive lewat `ndw backup --ssh`), bukan di git.

---

## Quick Start (PC/Mac Baru)

### Option A: One-line install (fastest)

Cukup install **Git** dulu (satu-satunya prasyarat manual — Windows: [Git for Windows](https://git-scm.com/download/win), macOS: `xcode-select --install`), lalu buka Git Bash/Terminal dan jalankan:

```bash
curl -fsSL https://raw.githubusercontent.com/nalfin/nalfin-developer-workstation/main/quickstart.sh | bash
```

Ini otomatis clone repo + install NDW. Lanjut ke [step 4](#4-restore-ssh-keys) di bawah.

### Option B: Manual, step by step

### 1. Install prerequisites

**Windows:**
- [Git for Windows](https://git-scm.com/download/win) — this gives you Git Bash, which is what runs everything below.
- [Warp](https://www.warp.dev/windows-terminal) — recommended terminal.

**macOS:**
- Xcode Command Line Tools: `xcode-select --install`
- [Warp](https://www.warp.dev) — recommended terminal.

### 2. Clone this repo

Open **Git Bash** (Windows) or **Terminal** (macOS) — or open **Warp**, which runs the same shell underneath:

```bash
mkdir -p ~/dev/platform
git clone https://github.com/nalfin/nalfin-developer-workstation.git \
  ~/dev/platform/nalfin-developer-workstation

cd ~/dev/platform/nalfin-developer-workstation
```

### 3. Install NDW

```bash
bash bootstrap/install
```

This restores your dotfiles (`gitconfig`, aliases, Starship prompt) and installs the `ndw` command.

### 4. Restore SSH keys

SSH keys are restored from Google Drive (encrypted zip), via `rclone`.

```bash
# First time only: install rclone, then connect it to your Google Drive
# Windows: winget install Rclone.Rclone
# macOS:   brew install rclone
rclone config
```

Setup rclone:
1. `n` → New remote → name: `gdrive`
2. Pilih nomor **Google Drive**
3. Scope: `1` → Auto config: `n`
4. Copy URL ke browser → login Google
5. Paste token ke terminal

Then:

```bash
ndw restore --ssh
```

Test koneksi:

```bash
ssh -T git@github.com
```

### 5. Bootstrap workspace

```bash
ndw bootstrap
```

Ini akan:
- Buat folder workspace (`~/dev/...`) dari `config/workspace.yaml`
- Install dotfiles symlinks (gitconfig, aliases, Starship)

### 6. Verifikasi

```bash
ndw doctor
```

### 7. (Opsional) Install tools

Node.js, PHP, Python, dll bukan bagian wajib NDW — install kalau/kapan dibutuhkan:

```bash
ndw setup
```

Ini nanya lewat menu, mau install apa (Node, PHP, Python, atau semua).

---

## Commands

| Command | Description |
|---|---|
| `ndw bootstrap` | Buat workspace folders + install dotfiles |
| `ndw doctor` | Cek environment health |
| `ndw backup --ssh` | Backup SSH keys ke Google Drive (encrypted) |
| `ndw restore --ssh` | Restore SSH keys dari Google Drive |

---

## Configuration

| File | Description |
|---|---|
| `config/workspace.yaml` | Folder struktur workspace |
| `dotfiles/gitconfig` | Git configuration |
| `dotfiles/aliases.sh` | Shell aliases (bash + zsh, sourced dari `.bashrc`/`.zshrc`) |
| `dotfiles/starship.toml` | Prompt (Starship — install manual lewat `ndw setup`) |

### Multiple Git identities (Personal vs Evocave)

`dotfiles/gitconfig` pakai `[includeIf "gitdir:~/dev/projects/evocave/"]` — otomatis switch identitas kalau kamu lagi di folder `~/dev/projects/evocave/`. Karena repo ini **public**, email Evocave kamu **tidak** ditaruh di sini. Buat sekali secara manual di device masing-masing (file ini nggak pernah masuk git):

```bash
cat > ~/.gitconfig-evocave << 'EOF'
[user]
    email = your-evocave-email@example.com
EOF
```

`ndw doctor` bakal ngingetin kalau file ini belum ada.

---

## Bootstrap Scripts

| Script | Description |
|---|---|
| `curl ... quickstart.sh \| bash` | One-line install on a brand new device (clones repo + `bootstrap/install`) |
| `bash bootstrap/install` | Install NDW CLI + dotfiles (wajib, sekali per device) |
| `ndw setup` | Install tools opsional (Node, PHP, Python, Warp, VS Code, dll) — bisa dipanggil dari mana aja |
| `ndw upgrade` | Update NDW ke versi terbaru — bisa dipanggil dari mana aja |
| `ndw uninstall` | Hapus NDW — bisa dipanggil dari mana aja |

---

## Backup & Restore (SSH Keys)

```bash
# Backup SSH keys (terenkripsi)
ndw backup --ssh

# Restore SSH keys di device baru
ndw restore --ssh
```

SSH keys disimpan di Google Drive: `NDW/ssh/` (terenkripsi dengan password yang kamu tentukan sendiri).

> ⚠️ Ingat password enkripsi SSH — tidak bisa dipulihkan jika lupa.

Database/service lokal (Postgres, Redis, dll) sengaja tidak ada di NDW — project di sini connect langsung ke Supabase (Postgres) dan Upstash (Redis), jadi tidak ada yang perlu di-backup secara lokal.

### Auto Backup (Windows)

Biar nggak lupa backup manual, ada opsi backup otomatis yang **cuma jalan kalau `~/.ssh` beneran berubah** (bukan jadwal buta) — dicek tiap login + tiap 1 jam, pakai Windows Scheduled Task (bukan proses yang nongkrong di RAM).

Setup sekali (dari **PowerShell**, bukan Git Bash):
```powershell
powershell -ExecutionPolicy Bypass -File bootstrap/windows/ndw-ssh-autobackup-setup.ps1
```
Ini minta password enkripsi sekali, disimpan terenkripsi (DPAPI, cuma bisa dibuka akun Windows kamu di device ini).

Cek log-nya:
```powershell
Get-Content "$env:USERPROFILE\.ndw\autobackup.log" -Tail 20
```

Matiin/hapus auto-backup:
```powershell
powershell -ExecutionPolicy Bypass -File bootstrap/windows/ndw-ssh-autobackup-remove.ps1
```

> macOS belum punya versi ini (butuh `launchd`, beda mekanisme dari Windows Scheduled Task) — nanti ditambahkan begitu ada device Mac aktif.

---

## Terminal Setup (Warp)

NDW tidak butuh zsh atau Powerlevel10k. Autosuggestion & syntax highlighting sudah bawaan Warp; alias & prompt di-handle lewat `dotfiles/aliases.sh` dan `dotfiles/starship.toml` di atas — keduanya jalan sama persis di Git Bash (Windows) maupun Terminal (macOS).

Opsional: arahkan VS Code untuk buka Warp lewat shortcut —
Settings → cari `terminal.external.windowsExec` → isi `%LOCALAPPDATA%\Programs\Warp\warp.exe`, lalu `Ctrl+Shift+C` di VS Code akan buka window Warp baru.

---

## Repository Layout

```
nalfin-developer-workstation/
├── bin/ndw                   # CLI entry point
├── bootstrap/
│   ├── install                # Install NDW CLI + dotfiles (wajib)
│   ├── setup                  # Install tools opsional (Node/PHP/Python/dll)
│   ├── dotfiles                # Install dotfiles symlinks
│   ├── uninstall               # Hapus NDW
│   └── upgrade                 # Update NDW
├── cli/
│   ├── app.sh                 # Load libs + delegate ke router
│   ├── router.sh               # Command dispatcher
│   ├── commands/                # bootstrap, doctor, backup, restore, help, version
│   └── lib/                     # Shared libraries (output, config, common, yaml)
├── config/
│   └── workspace.yaml          # Folder struktur
└── dotfiles/
    ├── gitconfig                # Git config
    ├── aliases.sh                # Shell aliases (bash + zsh)
    └── starship.toml             # Prompt config
```
