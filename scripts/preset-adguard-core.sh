#!/usr/bin/env bash
set -euo pipefail

ARCH="amd64"

# 1) 自动检测构建根目录（优先 ImmortalWRT、openwrt，否则用 GITHUB_WORKSPACE）
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

echo "列出压缩包内容以查找二进制路径..."
# 查找名字为 AdGuardHome（可在任意目录下）的条目（文件名正好是 AdGuardHome）
binpath=$(tar -tzf "${tmpdir}/agh.tar.gz" | awk -F/ '/(^|\/)AdGuardHome$/ {print; exit}')
if [ -z "${binpath}" ]; then
  echo "错误：在压缩包中没有找到名为 AdGuardHome 的可执行条目"
  echo "压缩包前几行内容："
  tar -tzf "${tmpdir}/agh.tar.gz" | sed -n '1,40p'
  exit 1
fi

echo "在压缩包中找到二进制：${binpath}"
echo "正在提取到 ${TARGET_BIN}/AdGuardHome ..."
if tar -xzf "${tmpdir}/agh.tar.gz" -O "${binpath}" > "${TARGET_BIN}/AdGuardHome"; then
  chmod +x "${TARGET_BIN}/AdGuardHome"
  echo "AdGuardHome 已放入 ${TARGET_BIN}/AdGuardHome"
  ls -l "${TARGET_BIN}/AdGuardHome" || true
else
  echo "错误：从压缩包中提取二进制失败"
  exit 1
fi