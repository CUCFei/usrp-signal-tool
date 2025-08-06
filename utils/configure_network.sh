#!/bin/bash
# ------------------------------------------------------------
# Ubuntu Server & Desktop 通用 有线网卡 DHCP↔静态回退脚本
# ------------------------------------------------------------
set -e

[[ $EUID -ne 0 ]] && { echo "Must run with sudo"; exit 1; }

if systemctl is-active --quiet NetworkManager.service 2>/dev/null; then
    RENDERER="NetworkManager"
else
    RENDERER="networkd"
fi

get_wired_iface() {
    local iface
    for iface in $(ip -o link | awk -F': ' '$2!="lo"{print $2}' | sed 's/@.*//'); do
        [[ $iface =~ ^(eth|enp|ens) ]] && { echo "$iface"; return 0; }
    done
    for iface in $(ip -o link | awk -F': ' '$2!="lo"{print $2}' | sed 's/@.*//'); do
        [[ ! $iface =~ ^(wlan|wlp) ]] && { echo "$iface"; return 0; }
    done
    return 1
}

IFACE=$(get_wired_iface)
[[ -z $IFACE ]] && { echo "未找到可用有线网卡"; exit 1; }

echo "网卡: $IFACE | 渲染器: $RENDERER"

# 4. 生成 netplan 文件
CONFIG="/etc/netplan/01-ethernet-config.yaml"
cat > "$CONFIG" <<EOF
network:
  version: 2
  renderer: $RENDERER
  ethernets:
    $IFACE:
      dhcp4: true
      dhcp4-overrides:
        route-metric: 100
      addresses: [192.168.100.100/24]   # DHCP 失败时的备用静态
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
      routes:
        - to: default
          via: 192.168.100.1
          metric: 200
EOF

# 5. 验证并应用
netplan generate
netplan apply

echo " 网络配置已生效（DHCP 优先，静态 192.168.100.100 备用）"
