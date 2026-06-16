#!/usr/bin/env bash
set -euo pipefail

ARCH="amd64"

# 1) 自动检测构建根目录
if [ -n "${GITHUB_WORKSPACE:-}" ] && [ -d "${GITHUB_WORKSPACE}/ImmortalWRT" ]; then
  BUILDROOT="${GITHUB_WORKSPACE}/ImmortalWRT"
elif [ -n "${GITHUB_WORKSPACE:-}" ] && [ -d "${GITHUB_WORKSPACE}/openwrt" ]; then
  BUILDROOT="${GITHUB_WORKSPACE}/openwrt"
elif [ -n "${GITHUB_WORKSPACE:-}" ]; then
  BUILDROOT="${GITHUB_WORKSPACE}"
else
  BUILDROOT="$(pwd)"
fi

TARGET_FILES="${BUILDROOT}/files"
TARGET_BIN="${TARGET_FILES}/usr/bin"
mkdir -p "${TARGET_BIN}"

AGH_CORE_URL="https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_linux_${ARCH}.tar.gz"
echo "AdGuardHome 下载地址: ${AGH_CORE_URL}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "正在下载到临时文件..."
if ! curl -fsSL -o "${tmpdir}/agh.tar.gz" "${AGH_CORE_URL}"; then
  echo "错误：下载 AdGuardHome 压缩包失败"
  exit 1
fi

echo "列出压缩包内容..."
# 不再用管道，先把文件列表写到临时文件，再读取
if ! tar -tzf "${tmpdir}/agh.tar.gz" > "${tmpdir}/filelist.txt" 2>&1; then
  echo "错误：读取压缩包元数据失败"
  cat "${tmpdir}/filelist.txt"
  exit 1
fi

echo "查找 AdGuardHome 二进制..."
binpath=$(grep -E '(^|/)AdGuardHome$' "${tmpdir}/filelist.txt" | head -1)

if [ -z "${binpath}" ]; then
  echo "错误：在压缩包中没有找到名为 AdGuardHome 的二进制"
  echo "压缩包前 20 行内容："
  head -20 "${tmpdir}/filelist.txt"
  exit 1
fi

echo "在压缩包中找到二进制：${binpath}"
echo "正在提取到 ${TARGET_BIN}/AdGuardHome ..."
if ! tar -xzf "${tmpdir}/agh.tar.gz" -O "${binpath}" > "${TARGET_BIN}/AdGuardHome" 2>&1; then
  echo "错误：从压缩包中提取二进制失败"
  exit 1
fi

chmod +x "${TARGET_BIN}/AdGuardHome"

# 验证文件
if [ -x "${TARGET_BIN}/AdGuardHome" ]; then
  echo "✓ AdGuardHome 已成功放入 ${TARGET_BIN}/AdGuardHome"
  ls -lh "${TARGET_BIN}/AdGuardHome"
  echo "文件大小: $(stat -f%z "${TARGET_BIN}/AdGuardHome" 2>/dev/null || stat -c%s "${TARGET_BIN}/AdGuardHome" 2>/dev/null || echo 'unknown')"
else
  echo "错误：文件验证失败（文件不存在或不可执行）"
  ls -la "${TARGET_BIN}/" || true
  exit 1
fi