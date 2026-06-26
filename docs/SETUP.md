# Setup Guide

Panduan lengkap setup workstation baru dari nol sampai siap kerja.

---

## Windows (Persiapan Awal)

Lakukan ini di Windows sebelum masuk ke WSL.

### 1. Install WSL2

Buka PowerShell sebagai Administrator:

```powershell
wsl --install
```

Restart PC, lalu set default ke WSL2:

```powershell
wsl --set-default-version 2
```

### 2. Install Ubuntu

```powershell
wsl --install -d Ubuntu
```

Buat username dan password saat diminta.

### 3. Install Docker Desktop

Download dari https://www.docker.com/products/docker-desktop

Setelah install:
- Buka Docker Desktop
- Settings → Resources → WSL Integration
- Enable untuk distro Ubuntu
- Apply & Restart

### 4. Install VS Code

Download dari https://code.visualstudio.com

### 5. Connect VS Code ke WSL

1. Buka VS Code
2. Install extension **WSL** by Microsoft
   - Extensions (Ctrl+Shift+X) → search "WSL" → Install
3. Klik icon **><** di pojok kiri bawah VS Code
4. Pilih **Connect to WSL**
5. Buka terminal: Terminal → New Terminal (otomatis masuk WSL)

Set default terminal ke WSL (opsional):
- Ctrl+Shift+P → "Terminal: Select Default Profile" → pilih "WSL"

---

## WSL (Setup Utama)

Semua langkah berikut dijalankan di dalam WSL terminal di VS Code.

### 1. Clone NDW

```bash
mkdir -p ~/dev/platform
git clone https://github.com/nalfin/nalfin-developer-workstation.git \
  ~/dev/platform/nalfin-developer-workstation
cd ~/dev/platform/nalfin-developer-workstation
```

### 2. Install semua tools otomatis

```bash
bash bootstrap/setup
```

Script ini akan otomatis install:
- Zsh + Oh My Zsh + Powerlevel10k
- zsh-autosuggestions, zsh-syntax-highlighting
- eza, bat, ripgrep, fd, zoxide, lazygit
- Node.js + pnpm
- Python + uv
- PHP + Composer
- rclone
- Folder struktur ~/dev/

### 3. Install NDW

```bash
bash bootstrap/install
source ~/.zshrc
```

### 4. Setup Google Drive (untuk backup)

```bash
rclone config
```

Ikuti langkah:
1. `n` → New remote
2. Name: `gdrive`
3. Pilih nomor Google Drive
4. Scope: `1` (full access)
5. Auto config: `n`
6. Copy URL yang muncul → buka di browser Windows → login Google
7. Paste token yang muncul di PowerShell ke terminal WSL

### 5. Verifikasi

```bash
ndw doctor
```

Semua checks harus ✓ hijau.

### 6. Start workspace

```bash
ndw work start
```

Services yang akan berjalan:
- PostgreSQL  → localhost:5432
- Redis       → localhost:6379
- Adminer     → http://localhost:8080
- Mailpit     → http://localhost:8025

### 7. Restore database (jika ada backup)

```bash
ndw restore --cloud
```

---

## Selesai!

Workstation siap digunakan. Total waktu estimasi ~30 menit.

```bash
ndw --help
```
