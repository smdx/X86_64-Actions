#!/bin/bash
set -euo pipefail  # 开启严格模式，减少脚本异常

# 自定义替换脚本 - 修复HASH/版本号替换问题
# 功能：批量替换Makefile中的 HASH（HASH值可以是目标文档任意内容）、PKG_VERSION、PKG_RELEASE
# 任务配置格式：每个任务单独定义变量组，直观易维护

# ========================= 任务配置区（核心修改：变量显式定义） =========================
# 说明：
# 1. 如需添加多个任务，复制以下变量组并修改后缀（如TASK2_XXX、TASK3_XXX）
# 2. 无需修改的字段赋值为空字符串 ""（不要留空格）
# 3. 路径/哈希/版本号直接写在双引号内

# 任务示例1：xray（修改HASH+PKG_VERSION+PKG_RELEASE）
# TASK1_MAKEFILE_PATH="feeds/small/xray-core/Makefile"
# TASK1_OLD_HASH="0b52df2117bacf2e32d1d3f98d09dbf88b274390733d3955699b108acaf9f2a6"
# TASK1_NEW_HASH="d4519b2d9bb1871f4d7612aa7a8db1c451573b5a44ac824219bb44d63f404e61"
# TASK1_NEW_VERSION="25.12.8"
# TASK1_NEW_RELEASE="1"

# 任务示例2：naiveproxy 仅修复HASH（不修改版本，示例）
# TASK2_MAKEFILE_PATH="feeds/small/naiveproxy/Makefile"
# TASK2_OLD_HASH="7387ce2af58463735d839f45d8564626cdc1baea3e053c2479ba5fe0f2fa721f"
# TASK2_NEW_HASH="5681e13c833757cfb5769755fd93d1906c47448af190585067bde9de590bdb2e"
# TASK2_NEW_VERSION=""  # 不修改PKG_VERSION
# TASK2_NEW_RELEASE=""  # 不修改PKG_RELEASE

# naiveproxy 143.0.7499.109-2 修复仓库HASH错误
TASK1_MAKEFILE_PATH="feeds/small/naiveproxy/Makefile"
TASK1_OLD_HASH="7387ce2af58463735d839f45d8564626cdc1baea3e053c2479ba5fe0f2fa721f"
TASK1_NEW_HASH="5681e13c833757cfb5769755fd93d1906c47448af190585067bde9de590bdb2e"
TASK1_NEW_VERSION=""
TASK1_NEW_RELEASE=""

# 任务列表（添加新任务时，需同步更新此列表，格式：("TASK1" "TASK2")）
TASKS=("TASK1")

# ========================= 核心处理逻辑 =========================
# 遍历所有任务
for TASK in "${TASKS[@]}"; do
  # 跳过未定义的任务（比如示例任务仅注释未删除时）
  if ! declare -p "${TASK}_MAKEFILE_PATH" &>/dev/null; then
    echo -e "\033[33m⚠️  跳过：任务 $TASK 未定义，忽略处理\033[0m"
    continue
  fi

  # 提取当前任务的参数（通过变量名拼接获取值）
  MAKEFILE_PATH=$(eval "echo \${${TASK}_MAKEFILE_PATH}")
  OLD_HASH=$(eval "echo \${${TASK}_OLD_HASH}")
  NEW_HASH=$(eval "echo \${${TASK}_NEW_HASH}")
  # 去除首尾空格，避免空值被误判为非空（核心修复点）
  NEW_VERSION=$(eval "echo \${${TASK}_NEW_VERSION}" | xargs 2>/dev/null || true)
  NEW_RELEASE=$(eval "echo \${${TASK}_NEW_RELEASE}" | xargs 2>/dev/null || true)

  # 1. 检查文件是否存在
  if [ ! -f "$MAKEFILE_PATH" ]; then
    echo -e "\033[33m⚠️  跳过[$TASK]：文件 $MAKEFILE_PATH 不存在\033[0m"
    continue
  fi

  # 2. 处理HASH替换（新旧HASH都非空时执行）
  if [ -n "$OLD_HASH" ] && [ -n "$NEW_HASH" ]; then
    # 转义HASH中的特殊字符（避免sed语法错误）
    OLD_HASH_ESC=$(echo "$OLD_HASH" | sed 's/[\/&]/\\&/g')
    NEW_HASH_ESC=$(echo "$NEW_HASH" | sed 's/[\/&]/\\&/g')
    # 执行替换
    sed -i "s/$OLD_HASH_ESC/$NEW_HASH_ESC/g" "$MAKEFILE_PATH"
    # 验证替换结果
    if grep -q "$NEW_HASH" "$MAKEFILE_PATH"; then
      echo -e "\033[32m✅ [$TASK] HASH替换成功：$MAKEFILE_PATH\033[0m"
    else
      echo -e "\033[34mℹ️ [$TASK] HASH未修改：$MAKEFILE_PATH（未找到旧HASH：$OLD_HASH）\033[0m"
    fi
  fi

  # 3. 处理PKG_VERSION替换（仅非空时执行，避免清空原有值）
  if [ -n "$NEW_VERSION" ]; then
    sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=$NEW_VERSION/" "$MAKEFILE_PATH"
    # 验证替换结果
    if grep -q "^PKG_VERSION:=$NEW_VERSION" "$MAKEFILE_PATH"; then
      echo -e "\033[32m✅ [$TASK] PKG_VERSION替换成功：$MAKEFILE_PATH → $NEW_VERSION\033[0m"
    else
      echo -e "\033[34mℹ️ [$TASK] PKG_VERSION未修改：$MAKEFILE_PATH（未找到目标行）\033[0m"
    fi
  fi

  # 4. 处理PKG_RELEASE替换（仅非空时执行，避免清空原有值）
  if [ -n "$NEW_RELEASE" ]; then
    sed -i "s/^PKG_RELEASE:=.*/PKG_RELEASE:=$NEW_RELEASE/" "$MAKEFILE_PATH"
    # 验证替换结果
    if grep -q "^PKG_RELEASE:=$NEW_RELEASE" "$MAKEFILE_PATH"; then
      echo -e "\033[32m✅ [$TASK] PKG_RELEASE替换成功：$MAKEFILE_PATH → $NEW_RELEASE\033[0m"
    else
      echo -e "\033[34mℹ️ [$TASK] PKG_RELEASE未修改：$MAKEFILE_PATH（未找到目标行）\033[0m"
    fi
  fi
done

echo -e "\033[32m✅ 所有任务处理完成！\033[0m"
