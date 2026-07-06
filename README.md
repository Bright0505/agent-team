# agent-team

一個可重複使用的多代理人開發團隊**專案模板**。本專案同時支援 **Claude Code** 與 **Antigravity (`agy`) / 通用 Agent**（基於 `AGENTS.md` 標準）。你可以透過 Tech Lead 角色自主委派 5 個子代理人角色，並留下各自的執行紀錄。

---

## 團隊結構

```
AI（Tech Lead / 協調者）
│
├── architect     ← 只在新功能 / 重構時啟動；邊界爭議的仲裁者
├── backend       ← 實作核心邏輯與共用 API client，收到真實錯誤後修改
├── frontend      ← 實作 UI 層，可呼叫既有 client，收到真實錯誤後修改
├── tester        ← 撰寫並實際執行測試，找邊界案例
└── reviewer      ← 直接修改問題並重跑測試，留下修改紀錄
```

在 Claude Code 中使用 `.claude/agents/` 定義角色；在 Antigravity (`agy`) / 通用 Agent 中使用 `.agents/skills/` 定義角色。

## 派工規則

| 任務類型 | 委派順序 |
|---------|---------|
| 新功能 / 重構 | architect → backend（+ frontend）→ tester → reviewer |
| Bug fix | backend 或 frontend → tester → reviewer |
| 純 UI 改動 | frontend → reviewer |
| 安全疑慮 | reviewer（直接） |

順序不是單向的：tester 測試失敗時，Tech Lead 會把完整失敗輸出帶回 backend/frontend 修正，
循環直到全數通過才進 reviewer；reviewer 修改程式碼後也必須重跑測試確認綠燈才結案。

## 協作機制

- **跨角色協商**：角色遇到職責邊界模糊時回報「立場 + 理由」，Tech Lead 居中傳話（最多 2 回合），
  無共識時由 architect 或 Tech Lead 仲裁，結果記入 `.claude/logs/decisions.md`，之後同類爭議直接沿用前例。
- **Tech Lead 先行調整**：typo 級的小修改 Tech Lead 可先動手，標記待確認，
  由負責角色在下次委派時確認並補 log，每筆都記入 `decisions.md`。
- **共享記憶**：`.claude/logs/` 是團隊的共享記憶——5 個角色各有一份執行紀錄，
  `decisions.md` 存跨角色共識；委派時附摘要、爭議時查前例，都以此為依據。

---

## 安裝

本 repo 定位是**模板**：以它為起點開新專案，角色開箱即用。

推薦做法——把 repo 設為 GitHub template repository 後：

```bash
gh repo create my-project --template <你的帳號>/agent-team --private --clone
cd my-project
# 角色已就緒，直接跟 Claude 描述任務即可
```

或手動：

```bash
git clone <agent-team-repo> my-project
cd my-project
rm -rf .git && git init            # 清掉模板歷史，開全新專案
git remote add origin <你的新 repo>
```

* **對於 Claude Code**：專案根目錄的 `CLAUDE.md` 及 `.claude/agents/` 設定會自動被載入。
* **對於 Antigravity (`agy`) / 通用 Agent**：專案根目錄的 `AGENTS.md` 規格，以及 `.agents/rules/` 與 `.agents/skills/` 設定會被自動發現。

`CLAUDE.md` 與 `AGENTS.md` 的上半部為協調規則，下半部留白供填入專案專屬規則。

同時，我們保留了 `.claude/settings.json` 的權限白名單以避免 Claude Code 頻繁提示。兩套工具的執行紀錄與決策歷程**均會統一寫入 `.claude/logs/`**，實現完美的團隊共享記憶。

---

## 使用方式

直接向 AI（Tech Lead）描述您的任務，它會自主依序委派角色：

> 「幫我實作 guard.ts，確保非測試店無法送單」

Tech Lead 判斷任務類型後，會依序委派 backend → tester → reviewer，每個角色完成後會把紀錄附加至 `.claude/logs/{role}.md`。

---

## 檔案結構

```
agent-team/
├── CLAUDE.md              ← Claude Code 協調與專案規則
├── AGENTS.md              ← Tool-agnostic/Antigravity 協調與專案規則
├── README.md
├── .gitignore
├── docs/
│   └── design-discussion-2026-07-03.md   ← 團隊設計的討論與決策紀錄
├── .agents/               ← Antigravity / 通用 Agent 設定
│   ├── rules/             ← 常駐規則（tech-lead.md 等）
│   └── skills/            ← 5 個角色 Skill 定義（含 SKILL.md）
└── .claude/               ← Claude Code 設定及團隊日誌
    ├── settings.json     ← 泛用權限白名單
    ├── agents/           ← 5 個 subagent 定義
    │   ├── architect.md
    │   ├── backend.md
    │   ├── frontend.md
    │   ├── tester.md
    │   └── reviewer.md
    └── logs/             ← 團隊共享記憶（各角色紀錄 + 跨角色共識，Claude Code 與 agy 共用）
        ├── architect.md
        ├── backend.md
        ├── frontend.md
        ├── tester.md
        ├── reviewer.md
        └── decisions.md  ← 邊界仲裁、先行調整、重大取捨
```
