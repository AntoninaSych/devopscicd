#!/usr/bin/env bash
# Purpose: Install Docker, Docker Compose, Python (>=3.9), and Django via pip on Ubuntu/Debian.
# The script is idempotent: it checks what's already installed and skips duplicates.
# Tested on: Ubuntu 20.04/22.04/24.04, Debian 11/12
# Notes:
# - Installs Docker Engine from the official Docker repo (if missing).
# - Installs the modern Compose plugin (usable as `docker compose`).
# - Installs Python 3.x (tries to ensure >=3.9) + pip + venv.
# - Installs Django via pip (user scope) if missing or too old.

set -euo pipefail

# ---------- UI helpers ----------
GREEN="\033[1;32m"; YELLOW="\033[1;33m"; RED="\033[1;31m"; BLUE="\033[1;34m"; NC="\033[0m"
info(){ echo -e "${BLUE}➤ $*${NC}"; }
ok(){ echo -e "${GREEN}✔ $*${NC}"; }
warn(){ echo -e "${YELLOW}⚠ $*${NC}"; }
err(){ echo -e "${RED}✖ $*${NC}" >&2; }

require_root(){
  if [[ $EUID -ne 0 ]]; then
    err "Please run as root (use: sudo $0)"; exit 1
  fi
}

# ---------- OS detection ----------
is_ubuntu(){ [[ -f /etc/lsb-release ]] && grep -qi ubuntu /etc/lsb-release; }
is_debian(){ [[ -f /etc/debian_version ]] && ! is_ubuntu; }

# ---------- APT refresh helper ----------
apt_refresh_once(){
  if [[ -z "${APT_REFRESHED:-}" ]]; then
    info "Updating APT package lists…"
    apt-get update -y
    APT_REFRESHED=1
  fi
}

# ---------- Docker ----------
install_docker(){
  if command -v docker >/dev/null 2>&1; then
    ok "Docker already installed: $(docker --version)"
    return
  fi

  info "Installing Docker Engine…"
  apt_refresh_once
  apt-get install -y ca-certificates curl gnupg lsb-release

  install_dir=/etc/apt/keyrings
  mkdir -p "$install_dir"
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | gpg --dearmor -o "$install_dir/docker.gpg"

  codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
  echo \
"deb [arch=$(dpkg --print-architecture) signed-by=$install_dir/docker.gpg] https://download.docker.com/linux/$(
  . /etc/os-release && echo "$ID"
) $codename stable" \
  | tee /etc/apt/sources.list.d/docker.list >/dev/null

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io

  # Enable & start
  systemctl enable docker
  systemctl restart docker

  ok "Docker installed: $(docker --version)"

  # Add current user to docker group (if running via sudo)
  if id -nG "${SUDO_USER:-$USER}" | grep -qvw docker; then
    info "Adding user '${SUDO_USER:-$USER}' to 'docker' group…"
    usermod -aG docker "${SUDO_USER:-$USER}" || warn "Could not add user to docker group."
    warn "You may need to log out/in (or reboot) for group changes to take effect."
  fi
}

# ---------- Docker Compose (plugin) ----------
install_compose(){
  # Prefer the v2 plugin (invoked as `docker compose`)
  if docker compose version >/dev/null 2>&1; then
    ok "Docker Compose plugin already installed: $(docker compose version | head -n1)"
    return
  fi

  info "Installing Docker Compose plugin…"
  apt_refresh_once
  # plugin package name
  apt-get install -y docker-compose-plugin || true

  if docker compose version >/dev/null 2>&1; then
    ok "Docker Compose plugin installed: $(docker compose version | head -n1)"
    return
  fi

  # Fallback: try legacy binary if plugin failed (not preferred, but ensures availability)
  if command -v docker-compose >/dev/null 2>&1; then
    ok "Legacy docker-compose already present: $(docker-compose --version)"
  else
    warn "Compose plugin not found; installing legacy docker-compose (fallback)…"
    apt_refresh_once
    apt-get install -y curl jq
    # Install latest release from GitHub (static binary)
    LATEST_URL=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[] | select(.name | test("linux-x86_64$")) | .browser_download_url' | head -n1 || true)
    if [[ -n "${LATEST_URL:-}" ]]; then
      curl -fsSL "$LATEST_URL" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
      ok "Legacy docker-compose installed: $(docker-compose --version)"
    else
      err "Could not determine latest docker-compose binary URL. Please install manually."
      exit 1
    fi
  fi
}

# ---------- Python (>= 3.9), pip, venv ----------
version_ge(){ # usage: version_ge "3.9" "3.10.12"
  # returns 0 if $2 >= $1
  dpkg --compare-versions "$2" ge "$1"
}

ensure_python(){
  info "Checking Python 3 availability…"
  PY_BIN=$(command -v python3 || true)
  if [[ -n "${PY_BIN}" ]]; then
    PY_VER=$($PY_BIN -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
    if version_ge "3.9" "$PY_VER"; then
      ok "Python already installed: ${PY_BIN} (v${PY_VER})"
    else
      warn "Python version ${PY_VER} < 3.9. Attempting to install a newer Python…"
      install_python_newer
    fi
  else
    info "Python 3 not found. Installing…"
    install_python_newer
  fi

  # Ensure pip & venv
  apt_refresh_once
  apt-get install -y python3-pip python3-venv || true

  # Re-resolve python3
  PY_BIN=$(command -v python3)
  PIP_BIN=$(command -v pip3 || true)

  if [[ -z "${PIP_BIN:-}" ]]; then
    err "pip3 not found after installation."
    exit 1
  fi

  ok "Python: $($PY_BIN --version)"
  ok "pip: $($PIP_BIN --version)"
}

install_python_newer(){
  apt_refresh_once
  # Try to install a modern Python available in repo first
  # Prefer 3.11, then 3.10, then 3.9
  candidates=(python3.11 python3.10 python3.9)
  installed=false
  for pkg in "${candidates[@]}"; do
    if apt-get install -y "$pkg" "$pkg-venv" python3-pip >/dev/null 2>&1; then
      update-alternatives --install /usr/bin/python3 python3 "/usr/bin/${pkg}" 1 || true
      installed=true
      break
    fi
  done

  if ! $installed; then
    # If Ubuntu and candidates unavailable, try deadsnakes PPA for newer Python
    if is_ubuntu; then
      info "Enabling deadsnakes PPA for newer Python…"
      apt-get install -y software-properties-common
      add-apt-repository -y ppa:deadsnakes/ppa
      apt-get update -y
      apt-get install -y python3.11 python3.11-venv python3-pip
      update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 || true
    else
      err "No suitable Python >=3.9 found in repos. Please enable backports or install manually."
      exit 1
    fi
  fi
}

# ---------- Django via pip (user scope) ----------
ensure_django(){
  # Use user scope to avoid system-wide pollution
  local PIP_BIN=$(command -v pip3)
  local PY_BIN=$(command -v python3)

  # Upgrade pip (user)
  info "Upgrading pip (user)…"
  sudo -u "${SUDO_USER:-$USER}" -H "$PIP_BIN" install --user --upgrade pip >/dev/null

  # Check existing Django
  if sudo -u "${SUDO_USER:-$USER}" -H "$PY_BIN" -c 'import django, sys; print(django.get_version())' >/dev/null 2>&1; then
    DJ_VER=$(sudo -u "${SUDO_USER:-$USER}" -H "$PY_BIN" -c 'import django; print(django.get_version())')
    ok "Django already installed (user scope): v${DJ_VER}"
  else
    info "Installing Django (user scope)…"
    sudo -u "${SUDO_USER:-$USER}" -H "$PIP_BIN" install --user "Django>=4.2,<6.0"
    DJ_VER=$(sudo -u "${SUDO_USER:-$USER}" -H "$PY_BIN" -c 'import django; print(django.get_version())')
    ok "Django installed: v${DJ_VER}"
  fi

  # Suggest adding ~/.local/bin to PATH if necessary
  local LOCALBIN="/home/${SUDO_USER:-$USER}/.local/bin"
  if ! sudo -u "${SUDO_USER:-$USER}" -H bash -lc "echo \$PATH" | grep -q "$LOCALBIN"; then
    warn "Make sure ~/.local/bin is in PATH to use user-installed CLIs (e.g., django-admin)."
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" | tee -a "/home/${SUDO_USER:-$USER}/.bashrc" >/dev/null
    ok "Added ~/.local/bin to PATH in user's .bashrc"
  fi
}

# ---------- Main ----------
main(){
  require_root

  info "Starting setup on $(. /etc/os-release && echo "$PRETTY_NAME")"
  if ! is_ubuntu && ! is_debian; then
    warn "This script targets Ubuntu/Debian. Proceeding anyway may fail."
  fi

  install_docker
  install_compose
  ensure_python
  ensure_django

  echo
  ok "All done!"
  echo
  info "Quick checks:"
  echo "  - Docker:           $(docker --version || true)"
  echo "  - Compose:          $(docker compose version 2>/dev/null | head -n1 || docker-compose --version || echo 'not found')"
  echo "  - Python:           $(python3 --version)"
  echo "  - pip:              $(pip3 --version)"
  echo "  - Django (import):  $(python3 -c 'import django,sys; print(django.get_version())' 2>/dev/null || echo 'not installed')"
  echo
  warn "If 'docker' says permission denied, log out/in (or reboot) to apply group changes."
}

main "$@"
