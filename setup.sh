#!/usr/bin/env bash
# 可選：全域安裝。把團隊角色 symlink 到 ~/.claude/agents/team，讓所有既有專案都能用。
# 若你採「鷹架模式」（git clone 本 repo 當新專案），不需要執行這支腳本。
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"

# 1. 清掉 v1 殘留的 commands symlink
if [ -L "$HOME/.claude/commands/team" ]; then
  echo "移除 v1 殘留：~/.claude/commands/team"
  rm "$HOME/.claude/commands/team"
fi

# 2. symlink agents 到全域
mkdir -p "$HOME/.claude/agents"
if [ -e "$HOME/.claude/agents/team" ] && [ ! -L "$HOME/.claude/agents/team" ]; then
  echo "警告：~/.claude/agents/team 已是實體目錄，請手動處理後再執行。"
  exit 1
fi
rm -f "$HOME/.claude/agents/team"
ln -sf "$DIR/.claude/agents" "$HOME/.claude/agents/team"
echo "✓ 已建立 symlink：~/.claude/agents/team → $DIR/.claude/agents"

# 3. 注入/更新 ~/.claude/CLAUDE.md 的協調區塊（BEGIN/END agent-team，idempotent）
mkdir -p "$HOME/.claude"
touch "$GLOBAL_CLAUDE"
BLOCK=$(cat <<'EOF'
<!-- BEGIN agent-team -->
## 開發團隊（agent-team）

接到開發任務時，依任務類型委派 team-* subagents（定義在 ~/.claude/agents/team/）：
- 新功能/重構：architect → backend(+frontend) → tester → reviewer
- Bug fix：backend 或 frontend → tester → reviewer
- 純 UI：frontend → reviewer
- 安全疑慮：reviewer

每個 subagent context 隔離，委派時必須在 prompt 帶入：任務描述、專案根目錄、相關檔案、前一角色產出摘要。
每個角色完成後紀錄寫入該專案的 .claude/logs/{role}.md（不存在則建立）。
<!-- END agent-team -->
EOF
)
TMP="$(mktemp)"
awk 'BEGIN{skip=0} /<!-- BEGIN agent-team -->/{skip=1} skip==0{print} /<!-- END agent-team -->/{skip=0}' "$GLOBAL_CLAUDE" > "$TMP"
# 移除尾端多餘空行後接上區塊
printf '%s\n\n%s\n' "$(cat "$TMP")" "$BLOCK" > "$GLOBAL_CLAUDE"
rm -f "$TMP"
echo "✓ 已更新 ~/.claude/CLAUDE.md 的 agent-team 協調區塊（既有內容保留）"

# 4. 提示如何把 logs seed 進既有專案
echo ""
echo "可用角色：architect / backend / frontend / tester / reviewer"
echo "在既有專案啟用 log 紀錄："
echo "  cp -r $DIR/.claude/logs {your-project}/.claude/logs"
