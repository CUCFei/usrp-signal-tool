#!/bin/bash
# utils/configure_env.sh - 项目环境配置脚本
# 功能：安装依赖、配置目录权限、初始化运行环境

set -e  # 遇到错误立即退出

# 检查是否以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：请使用root权限运行此脚本（sudo ./configure_env.sh）"
    exit 1
fi

# 定义项目根目录（脚本所在目录的上级目录）
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
echo "检测到项目根目录：$PROJECT_ROOT"

# 定义需要的目录
DIRS=(
    "$PROJECT_ROOT/uploads"
    "$PROJECT_ROOT/records"
    "$PROJECT_ROOT/utils"
)

# 创建目录并设置权限
echo "创建必要目录并配置权限..."
for dir in "${DIRS[@]}"; do
    mkdir -p "$dir"
    chmod 775 "$dir"
    # 授予当前用户目录权限（避免root创建的目录普通用户无法访问）
    chown -R "$SUDO_USER:$SUDO_USER" "$dir"
done

# 安装系统依赖
echo "安装系统依赖包..."
apt update && apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    uhd-host \
    libuhd-dev \
    git \
    netplan.io \
    build-essential

# 验证UHD安装
echo "验证UHD安装..."
if ! command -v uhd_find_devices &> /dev/null; then
    echo "错误：UHD工具未找到，请检查安装"
    exit 1
fi

# 安装Python依赖
echo "安装Python依赖..."
# 可选：创建虚拟环境
read -p "是否使用Python虚拟环境？(y/n，默认n) " use_venv
if [ "$use_venv" = "y" ] || [ "$use_venv" = "Y" ]; then
    VENV_DIR="$PROJECT_ROOT/venv"
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip
fi

# 安装Python包
pip install \
    flask \
    flask-cors \
    numpy \
    scipy \
    pyyaml

# 配置UHD固件（如果需要）
echo "检查UHD固件..."
uhd_images_downloader || echo "注意：UHD固件下载可能需要手动完成，不影响基础功能"

# 复制网络配置脚本到utils目录（如果不存在）
if [ ! -f "$PROJECT_ROOT/utils/configure_network.sh" ]; then
    echo "复制网络配置脚本..."
    cp "$PROJECT_ROOT/configure_network.sh" "$PROJECT_ROOT/utils/" 2>/dev/null || true
    chmod +x "$PROJECT_ROOT/utils/configure_network.sh"
fi

# 显示配置完成信息
echo "=============================================="
echo "环境配置完成！"
echo "项目目录：$PROJECT_ROOT"
echo "可用工具："
echo "  - 网络配置：sudo ./utils/configure_network.sh"
echo "  - 启动应用：python3 $PROJECT_ROOT/app.py"
if [ "$use_venv" = "y" ] || [ "$use_venv" = "Y" ]; then
    echo "  - 激活虚拟环境：source $VENV_DIR/bin/activate"
fi
echo "=============================================="