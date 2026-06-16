#!/usr/bin/env bash
set -euo pipefail

ARCH="amd64"

# 如果通过环境变量传入 TARGET_FILES，就用它；否则用默认值
if [ -z "${TARGET_FILES:-}" ]; then
  TARGET_FILES="${GITHUB_WORKSPACE}/ImmortalWRT/files"
fi

TARGET_BIN="${TARGET_FILES}/usr/bin"
TARGET_FILE="${TARGET_BIN}/AdGuardHome"

# 确保 parent 目录存在
mkdir -p "${TARGET_BIN}"

# 如果目标文件已存在（可能是目录或旧文件），删除它
if [ -e "${TARGET_FILE}" ]; then
  echo "删除已存在的目标: ${TARGET_FILE}"
  rm -rf "${TARGET_FILE}"
fi

echo "目标 files 目录: ${TARGET_FILES}"

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
echo "正在提取到 ${TARGET_FILE} ..."
if ! tar -xzf "${tmpdir}/agh.tar.gz" -O "${binpath}" > "${TARGET_FILE}" 2>&1; then
  echo "错误：从压缩包中提取二进制失败"
  exit 1
fi

chmod +x "${TARGET_FILE}"

# 验证文件
if [ -x "${TARGET_FILE}" ]; then
  echo "✓ AdGuardHome 已成功放入 ${TARGET_FILE}"
  ls -lh "${TARGET_FILE}"
  file_size=$(stat -f%z "${TARGET_FILE}" 2>/dev/null || stat -c%s "${TARGET_FILE}" 2>/dev/null || echo 'unknown')
  echo "文件大小: ${file_size}"
else
  echo "错误：文件验证失败（文件不存在或不可执行）"
  ls -la "${TARGET_BIN}/" || true
  exit 1
fi
