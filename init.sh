#!/usr/bin/env bash
# 一键初始化脚本（Debian/Ubuntu，root 自用）
# 功能：基础工具 + zsh + oh-my-zsh + Docker + BBR

set -euo pipefail

# 前置检查
[ "$EUID" -eq 0 ] || { echo "请使用 root 运行"; exit 1; }

. /etc/os-release
case "$ID" in
    debian|ubuntu) ;;
    *) echo "只支持 Debian 和 Ubuntu"; exit 1 ;;
esac

SUITE="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
[ -n "$SUITE" ] || { echo "无法读取系统版本代号"; exit 1; }

echo "==> 系统：$ID ($SUITE)"

# 基础工具
echo "==> 安装基础工具"
apt update
apt install -y sudo curl git tmux gcc neovim zsh ca-certificates

# zsh + oh-my-zsh
echo "==> 配置 zsh"
chsh -s "$(command -v zsh)"
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh |
    RUNZSH=no CHSH=no sh -s -- --unattended

# Docker
echo "==> 配置 Docker 源"
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

echo "==> 安装 Docker"
apt update
apt install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

docker run hello-world

# BBR
echo "==> 尝试启用 BBR"
modprobe tcp_bbr 2>/dev/null || true
if grep -qw bbr /proc/sys/net/ipv4/tcp_available_congestion_control; then
    cat > /etc/sysctl.d/99-bbr.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
    sysctl -p /etc/sysctl.d/99-bbr.conf
    echo "==> BBR 已启用"
else
    echo "!! 当前内核不支持 BBR，已跳过"
fi

echo
echo "安装完成。请注销后重新登录以使用 zsh。"
