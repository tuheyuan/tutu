#!/bin/bash

# Miniconda 安装脚本（Linux，使用清华源）
set -e

# 自动检测架构
ARCH="$(uname -m)"
[ "$ARCH" != "x86_64" ] && [ "$ARCH" != "aarch64" ] && echo "不支持的架构: $ARCH" && exit 1

# 使用清华源下载 Miniconda
echo "正在从清华源下载 Miniconda..."
INSTALLER="miniconda.sh"
URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-${ARCH}.sh"

# 使用 wget 或 curl 下载
if command -v wget >/dev/null; then
    wget -O "$INSTALLER" "$URL"
elif command -v curl >/dev/null; then
    curl -o "$INSTALLER" "$URL"
else
    echo "需要安装 wget 或 curl" && exit 1
fi

# 安装 Miniconda
bash "$INSTALLER" -b -p "$HOME/miniconda3"
# rm -f "$INSTALLER"

# 初始化 conda
source "$HOME/miniconda3/bin/activate"
conda init

# 配置 conda 使用清华源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --set show_channel_urls yes

echo "Miniconda 安装完成！"
echo "请运行 'source ~/.bashrc' 或重新打开终端以生效。"
echo "验证安装：conda --version"
