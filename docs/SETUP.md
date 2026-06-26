cat > docs/SETUP.md << 'EOF'
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

Install extension **WSL** dari Microsoft supaya bisa buka project di dalam WSL.

---

## WSL (Setup Utama)

Semua langkah berikut dijalankan di dalam WSL terminal.

### 1. Update system

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install dependencies

```bash
sudo apt install -y git curl wget unzip zsh
```

### 3. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 4. Install Powerlevel10k

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 5. Install Zsh plugins

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 6. Install modern CLI tools

```bash
sudo apt install -y eza bat ripgrep fd-find

# zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
```

### 7. Install Node.js

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```

Install pnpm:

```bash
npm install -g pnpm
```

### 8. Install Python + uv

```bash
sudo apt install -y python3 python3-pip

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 9. Install PHP + Composer

```bash
sudo apt install -y php php-cli php-mbstring php-xml php-curl unzip

# Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### 10. Install rclone (untuk backup Google Drive)

```bash
curl https://rclone.org/install.sh | sudo bash
```

Setup Google Drive:

```bash
rclone config
# Pilih: n → gdrive → 24 (Google Drive) → scope: 1 → auto config: n
# Copy URL yang muncul ke browser Windows untuk login Google
```

### 11. Setup workspace folder

```bash
mkdir -p ~/dev/{platform,personal,clients,playground}
mkdir -p ~/dev/evocave
```

### 12. Clone NDW

```bash
git clone https://github.com/nalfin/nalfin-developer-workstation.git \
  ~/dev/platform/nalfin-developer-workstation
```

### 13. Install NDW

```bash
cd ~/dev/platform/nalfin-developer-workstation
bash bootstrap/install
source ~/.zshrc
```

### 14. Verifikasi

```bash
ndw doctor
```

Semua checks harus ✓ hijau.

### 15. Start workspace

```bash
ndw work start
```

### 16. Restore database (jika ada backup)

```bash
ndw restore --cloud
```

---

## Selesai!

Workstation siap digunakan. Total waktu: ~30 menit.