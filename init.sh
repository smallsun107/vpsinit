#!/usr/bin/env bash

set -e

[ "$EUID" -eq 0 ] || { echo "请使用 root 运行"; exit 1; }

. /etc/os-release
case "$ID" in
    debian|ubuntu) ;;
    *) echo "只支持 Debian 和 Ubuntu"; exit 1 ;;
esac

SUITE="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
[ -n "$SUITE" ] || { echo "无法读取系统版本代号"; exit 1; }

# 基础工具和 zsh
apt update
apt install -y sudo curl git tmux gcc neovim zsh ca-certificates
chsh -s "$(command -v zsh)"
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -- --unattended

# Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/$ID/gpg" -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/$ID
Suites: $SUITE
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker run hello-world

# BBR（内核支持时启用）
if grep -qw bbr /proc/sys/net/ipv4/tcp_available_congestion_control; then
    cat > /etc/sysctl.d/99-bbr.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
    sysctl -p /etc/sysctl.d/99-bbr.conf
fi

echo "安装完成，请重新登录。"
