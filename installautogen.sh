#!/bin/bash

# 设置变量
MINICONDA_INSTALLER=Miniconda3-latest-Linux-x86_64.sh
MINICONDA_URL=https://mirror.nyist.edu.cn/anaconda/miniconda/$MINICONDA_INSTALLER
# MINICONDA_URL=https://mirrors.ustc.edu.cn/anaconda/miniconda/$MINICONDA_INSTALLER
ENV_NAME=autogen_env
PYTHON_VERSION=3.11

# # 下载 Miniconda 安装脚本
# echo "Downloading Miniconda installer..."
# wget $MINICONDA_URL -O $MINICONDA_INSTALLER

# 安装 Miniconda
echo "Installing Miniconda..."
bash $MINICONDA_INSTALLER -b -p $HOME/miniconda

# 初始化 Conda
echo "Initializing Conda..."
source $HOME/miniconda/bin/conda init
source ~/.bashrc

# # 配置 Conda 使用 USTC 镜像源
# echo "Configuring Conda to use USTC mirror..."
# cat >~/.condarc <<EOL
# channels:
#   - defaults
# show_channel_urls: true
# default_channels:
#   - https://mirrors.ustc.edu.cn/anaconda/pkgs/main
#   - https://mirrors.ustc.edu.cn/anaconda/pkgs/r
#   - https://mirrors.ustc.edu.cn/anaconda/pkgs/msys2
# custom_channels:
#   conda-forge: https://mirrors.ustc.edu.cn/anaconda/cloud
#   bioconda: https://mirrors.ustc.edu.cn/anaconda/cloud
# EOL

# # 清理 Conda 缓存
# echo "Cleaning Conda cache..."
# conda clean -i

# # 创建并激活 Python 3.11 虚拟环境
# echo "Creating and activating Python $PYTHON_VERSION environment..."
# conda create -n $ENV_NAME python=$PYTHON_VERSION -y
# conda activate $ENV_NAME

# # 安装 AutoGen Studio
# echo "Installing AutoGen Studio..."
# pip install autogenstudio -i https://mirrors.aliyun.com/pypi/simple

# # 启动 AutoGen Studio 在 8080 端口
# echo "Starting AutoGen Studio on port 8080..."
# autogenstudio ui --host 0.0.0.0 --port 8080
