#!/bin/sh
# myskill 技能安装脚本
# 用法:
#   ./install.sh last30days-cn
#   ./install.sh list
#   curl -fsSL https://raw.githubusercontent.com/HakunaMatata-zz/myskill/main/install.sh | sh -s last30days-cn

set -e

REPO="HakunaMatata-zz/myskill"
BRANCH="main"
SKILL="${1:-}"

if [ -z "$SKILL" ] || [ "$SKILL" = "list" ]; then
  echo "可用技能："
  echo "  last30days-cn   中文互联网热点搜集与研究（微博/小红书/B站/知乎/抖音/公众号/百度/头条）"
  echo
  echo "安装: $0 last30days-cn"
  exit 0
fi

# 探测目标技能目录：已存在的优先，否则默认 Claude Code
pick_target() {
  for d in "$HOME/.claude/skills" "$HOME/.workbuddy/skills" "$HOME/.codex/skills"; do
    if [ -d "$d" ]; then echo "$d"; return; fi
  done
  echo "$HOME/.claude/skills"
}

TARGET_DIR="${SKILLS_DIR:-$(pick_target)}"
TARGET="$TARGET_DIR/$SKILL"

echo "→ 目标目录: $TARGET"

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t myskill)
trap 'rm -rf "$TMP"' EXIT

echo "→ 下载 $REPO ..."
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" | tar -xz -C "$TMP"

SRC="$TMP/myskill-$BRANCH/skills/$SKILL"
if [ ! -d "$SRC" ]; then
  echo "✗ 未找到技能: $SKILL"
  echo "  可用技能请运行: $0 list"
  exit 1
fi

mkdir -p "$TARGET_DIR"
rm -rf "$TARGET"
cp -r "$SRC" "$TARGET"

echo "✓ 已安装到 $TARGET"
echo
if [ -f "$TARGET/SKILL.md" ]; then
  echo "技能说明: $TARGET/SKILL.md"
fi
echo "重启 Agent 会话后即可调用。"
