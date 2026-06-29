# agent-team

一個可重複使用的 Claude 開發團隊。把 5 個角色定義成 Claude Code 的 **subagents**，Claude 以 Tech Lead 身份依任務類型自主委派，每個角色留下各自的紀錄供未來參考。

---

## 團隊結構

```
Claude（Tech Lead / 協調者）
│
├── architect     ← 只在新功能 / 重構時啟動（model: opus）
├── backend       ← 實作核心邏輯，收到真實錯誤後修改（model: sonnet）
├── frontend      ← 實作 UI 層，收到真實錯誤後修改（model: sonnet）
├── tester        ← 撰寫實際測試 code，找邊界案例（model: sonnet）
└── reviewer      ← 直接修改問題，留下修改紀錄（model: opus）
```

各角色是真正的 subagent（`.claude/agents/`），有獨立 context、各自的工具與模型。

## 派工規則

| 任務類型 | 委派順序 |
|---------|---------|
| 新功能 / 重構 | architect → backend（+ frontend）→ tester → reviewer |
| Bug fix | backend 或 frontend → tester → reviewer |
| 純 UI 改動 | frontend → reviewer |
| 安全疑慮 | reviewer（直接） |

---

## 安裝模式

### 模式 A — 鷹架（預設，零安裝）

把本 repo 當成新專案的起點，角色開箱即用：

```bash
git clone <agent-team-repo> my-project
cd my-project
rm -rf .git && git init            # 清掉鷹架歷史，開全新專案
git remote add origin <你的新 repo>
# 角色已就緒，直接跟 Claude 描述任務即可
```

clone 下來的 `.claude/agents/` 正好落在專案根，Claude Code 一開工就自動發現；
根目錄 `CLAUDE.md` 上半部是協調規則（沿用），下半部留白給你填專案專屬規則。

### 模式 B — 全域（可選）

讓團隊在**所有既有專案**都能用：

```bash
bash setup.sh
# symlink .claude/agents → ~/.claude/agents/team
# 並在 ~/.claude/CLAUDE.md 注入協調區塊（idempotent，不動既有內容）
```

要在某個既有專案啟用 log 紀錄：

```bash
cp -r .claude/logs {your-project}/.claude/logs
```

---

## 使用方式

直接跟 Claude 描述任務，Tech Lead 會自主委派對應角色：

> 「幫我實作 guard.ts，確保非測試店無法送單」

Claude 判斷類型後，依序委派 backend → tester → reviewer，
每個角色完成後把紀錄寫入 `.claude/logs/{role}.md`。

---

## 檔案結構

```
agent-team/
├── CLAUDE.md              ← 協調規則 + 專案規則留白
├── README.md
├── setup.sh              ← 可選：全域安裝
├── .gitignore
└── .claude/
    ├── agents/           ← 5 個 subagent 定義（含 frontmatter）
    │   ├── architect.md
    │   ├── backend.md
    │   ├── frontend.md
    │   ├── tester.md
    │   └── reviewer.md
    └── logs/             ← 5 個 log（鷹架模式直接用 / 全域模式作 seed 來源）
        ├── architect.md
        ├── backend.md
        ├── frontend.md
        ├── tester.md
        └── reviewer.md
```
