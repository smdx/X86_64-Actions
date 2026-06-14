#!/bin/bash
# 固定架构为 amd64
ARCH="amd64"
# 读取 Action 环境变量 FILES = ImmortalWRT/files
TARGET_FILES="${FILES}"

# 拼接完整路径：ImmortalWRT/files/usr/bin/AdGuardHome
mkdir -p "${TARGET_FILES}/usr/bin/AdGuardHome"

# 下载 amd64 版本 AdGuardHome
AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep /AdGuardHome_linux_${ARCH} | awk -F '"' '{print $4}')

# 只提取压缩包中的 AdGuardHome/AdGuardHome 文件
wget -qO- "$AGH_CORE" | tar xz -O './AdGuardHome/AdGuardHome' > "${TARGET_FILES}/usr/bin/AdGuardHome/AdGuardHome"

chmod +x "${TARGET_FILES}/usr/bin/AdGuardHome/AdGuardHome"