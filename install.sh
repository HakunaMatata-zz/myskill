#!/bin/sh
# myskill 技能安装脚本
# 用法:
#   ./install.sh last30days-cn     # 装单个技能
#   ./install.sh drama             # 装 short-drama 全家桶（12 个）
#   ./install.sh all               # 装全部
#   ./install.sh list              # 看清单
#   curl -fsSL https://raw.githubusercontent.com/HakunaMatata-zz/myskill/main/install.sh | sh -s drama

set -e

REPO="HakunaMatata-zz/myskill"
BRANCH="main"
ARG="${1:-}"

DRAMA_SKILLS="short-drama short-drama-develop short-drama-novel-analyze short-drama-breakdown short-drama-write short-drama-assets short-drama-image-prompts short-drama-storyboard short-drama-video-prompts short-drama-produce short-drama-edit short-drama-review"
ALL_SKILLS="last30days-cn $DRAMA_SKILLS"

show_list() {
  echo "可用技能："
  echo "  last30days-cn         中文互联网热点搜集与研究（微博/小红书/B站/知乎/抖音/公众号/百度/头条）"
  echo "  drama                 short-drama 全家桶，AI 短剧/漫剧全流程（12 个技能）"
  echo "  all                   以上全部"
  echo
  echo "单装漫剧子技能也可以，例如: $0 short-drama-write"
  echo
  echo "子技能: $DRAMA_SKILLS"
}

if [ -z "$ARG" ] || [ "$ARG" = "list" ] || [ "$ARG" = "--help" ] || [ "$ARG" = "-h" ]; then
  show_list
  exit 0
fi

case "$ARG" in
  drama|short-drama-suite) TARGETS="$DRAMA_SKILLS" ;;
  all) TARGETS="$ALL_SKILLS" ;;
  *) TARGETS="$ARG" ;;
esac

# 探测目标技能目录：已存在的优先，否则默认 Claude Code
pick_target() {
  for d in "$HOME/.claude/skills" "$HOME/.workbuddy/skills" "$HOME/.codex/skills"; do
    if [ -d "$d" ]; then echo "$d"; return; fi
  done
  echo "$HOME/.claude/skills"
}

TARGET_DIR="${SKILLS_DIR:-$(pick_target)}"
echo "→ 目标目录: $TARGET_DIR"

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t myskill)
trap 'rm -rf "$TMP"' EXIT

echo "→ 下载 $REPO ..."
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" | tar -xz -C "$TMP"
ROOT="$TMP/myskill-$BRANCH/skills"

mkdir -p "$TARGET_DIR"
INSTALLED=""
FAILED=""

for skill in $TARGETS; do
  if [ ! -d "$ROOT/$skill" ]; then
    FAILED="$FAILED $skill"
    continue
  fi
  rm -rf "$TARGET_DIR/$skill"
  cp -r "$ROOT/$skill" "$TARGET_DIR/$skill"
  INSTALLED="$INSTALLED $skill"
done

if [ -n "$INSTALLED" ]; then
  echo "✓ 已安装:"
  for s in $INSTALLED; do echo "    $TARGET_DIR/$s"; done
fi

if [ -n "$FAILED" ]; then
  echo "✗ 未找到:$FAILED"
  echo "  运行 $0 list 查看可用技能"
  exit 1
fi

echo
echo "重启 Agent 会话后即可调用。漫剧系列从 short-drama 入口进。"
