#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请以 root 权限运行此脚本"
    exit 1
fi

# 设置虚拟环境名称
ENV_NAME="dify_env"

# 创建 Conda 虚拟环境
echo "创建 Conda 虚拟环境：$ENV_NAME..."
conda create -n $ENV_NAME python=3.10 -y

# 激活虚拟环境
echo "激活虚拟环境..."
source activate $ENV_NAME

# 检查并安装 Docker
echo "检查 Docker 是否已安装..."
if ! command -v docker &> /dev/null
then
    echo "Docker 未安装，正在安装 Docker..."
    apt update
    apt install -y docker.io
    systemctl start docker
    systemctl enable docker
    
    # 验证 Docker 服务状态
    if ! systemctl is-active --quiet docker; then
        echo "Docker 服务启动失败，请检查系统日志"
        exit 1
    fi
else
    echo "Docker 已安装。"
fi

# 检查并安装 Docker Compose
echo "检查 Docker Compose 是否已安装..."
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose 未安装，正在安装 Docker Compose..."
    apt install -y docker-compose
else
    echo "Docker Compose 已安装。"
fi

# 测试 Docker 是否可以正常运行
echo "测试 Docker 连接..."
if ! docker info >/dev/null 2>&1; then
    echo "Docker 守护进程无法连接，请检查 Docker 服务状态"
    exit 1
fi

# 克隆 Dify 仓库
echo "检查 Dify 仓库..."
if [ ! -d "dify" ]; then
    echo "克隆 Dify 仓库..."
    git clone https://github.com/langgenius/dify.git --branch 0.15.5
    cd dify/docker || exit 1
    cp .env.example .env
else
    echo "Dify 仓库已存在，直接使用..."
    cd dify/docker || exit 1
    if [ ! -f ".env" ]; then
        cp .env.example .env
    fi
fi

# 启动 Dify 服务
echo "启动 Dify 服务..."
if ! docker-compose up -d; then
    echo "Dify 服务启动失败，请检查 Docker 日志"
    exit 1
fi

# 检查 Dify 服务状态
echo "检查 Dify 服务状态..."
docker ps

# 等待服务启动
echo "等待服务启动..."
sleep 30

# 检查服务是否正常运行
if curl -s http://localhost >/dev/null; then
    echo "Dify 安装完成！请访问 http://localhost 进行访问。"
else
    echo "Dify 服务似乎未正常运行，请检查 Docker 容器日志"
    docker-compose logs
    exit 1
fi