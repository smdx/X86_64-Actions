#!/bin/bash
# 固定架构为 amd64
ARCH="amd64"
# 读取 Action 环境变量 FILES = ImmortalWRT/files
TARGET_FILES="${GITHUB_WORKSPACE}/ImmortalWRT/files"

# 拼接完整路径：ImmortalWRT/files/usr/bin/AdGuardHome
mkdir -p "${TARGET_FILES}/usr/bin"

# 下载 amd64 版本 AdGuardHome - 更可靠的提取方式
echo "正在获取 AdGuardHome 最新版本..."
AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | \
           grep -o '"browser_download_url": "[^"]*AdGuardHome_linux_'${ARCH}'[^"]*' | \
           grep -o 'http[^"]*' | head -1)

if [ -z "$AGH_CORE" ]; then
    echo "错误：无法获取 AdGuardHome 下载链接"
    exit 1
fi

echo "下载链接: $AGH_CORE"

# 只提取压缩包中的 AdGuardHome/AdGuardHome 文件
echo "正在下载并解压 AdGuardHome..."
if wget -qO- "$AGH_CORE" | tar xz -O './AdGuardHome/AdGuardHome' > "${TARGET_FILES}/usr/bin/AdGuardHome"; then
    chmod +x "${TARGET_FILES}/usr/bin/AdGuardHome"
    echo "AdGuardHome 核心下载成功"
else
    echo "错误：AdGuardHome 核心下载失败"
    exit 1
fi