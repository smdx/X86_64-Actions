#!/bin/bash

# 自定义临时脚本

# 替换任务列表：每行一组，格式「文件路径|目标内容|替换内容」
# 排版说明：每个字段分行写，便于复制/修改，末尾用反斜杠连接
REPLACE_TASKS=(
  # 示例1：xray
  #"feeds/small/xray/Makefile" \
  #"aaa7890aaa7890aaa7890aaa7890aaa7890aaa7890aaa7890aaa7890aaaaa" \
  #"bbb0123bbb0123bbb0123bbb0123bbb0123bbb0123bbb0123bbb0123bbbbb"

  # 示例2：v2ray（新增/修改只需复制这段模板）
  #"feeds/small/v2ray/Makefile" \
  #"abc1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcd" \
  #"def67890abcdef1234567890abcdef1234567890abcdef1234567890abcde123"

  # 继续添加：复制上面3行，替换路径和指定内容即可

  # naiveproxy 143.0.7499.109-2 修复仓库HASH错误
  "feeds/small/naiveproxy/Makefile" \
  "7387ce2af58463735d839f45d8564626cdc1baea3e053c2479ba5fe0f2fa721f" \
  "5681e13c833757cfb5769755fd93d1906c47448af190585067bde9de590bdb2e"
  
)

# 循环处理（3个元素为一组，对应 文件|旧HASH|新HASH）
for ((i=0; i<${#REPLACE_TASKS[@]}; i+=3)); do
  FILE="${REPLACE_TASKS[$i]}"
  OLD_HASH="${REPLACE_TASKS[$i+1]}"
  NEW_HASH="${REPLACE_TASKS[$i+2]}"

  # 跳过不存在的文件（避免报错）
  [ ! -f "$FILE" ] && echo "⚠️  跳过：文件 $FILE 不存在" && continue

  # 无备份原地替换（核心命令）
  sed -i "s/$OLD_HASH/$NEW_HASH/g" "$FILE"

  # 简洁验证提示
  grep -q "$NEW_HASH" "$FILE" && echo "✅ 成功：$FILE" || echo "ℹ️  未改：$FILE（未找到指定内容）"
done