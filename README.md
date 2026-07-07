# agent-team

一個可重複使用的多代理人開發團隊**專案模板**。以成熟產品公司的完整分工為標準建置：從功能規格書、web design guideline 到實作、測試、審查，每個環節都有專責角色與對應文件。本專案同時支援 **Claude Code** 與 **Antigravity (`agy`) / 通用 Agent**（基於 `AGENTS.md` 標準）。你可以透過 Tech Lead 角色自主委派 7 個子代理人角色，並留下各自的執行紀錄。

---

## 團隊結構

| 產品公司標準角色 | 本團隊角色 | 產出 |
|----------------|-----------|------|
| Product Manager（功能規格書） | **product-manager** | `docs/prd/PRD.md`、`docs/specs/` 功能規格書 |
| UX/UI Designer（web design guideline） | **ui-designer** | `docs/design/web-design-guideline.md`、wireframe |
| Software Architect | **architect** | 模組切分、介面定義、技術選型 |
| Backend Engineer | **backend** | 核心邏輯、API 整合、共用 client |
| Frontend Engineer | **frontend** | UI 實作、互動邏輯、瀏覽器/Extension |
| QA Engineer | **tester** | 把驗收條件轉成可執行測試，覆蓋紅線與邊界 |
| Senior Reviewer | **reviewer** | 最終把關：紅線、規格忠實度、一致性，直接修正 |

```
AI（Tech Lead / 協調者）
│
├── product-manager ← 需求/業務規則的第一站；產品方向爭議的仲裁者
├── ui-designer     ← 維護 web 設計規範與 wireframe，規範不足先補規範
├── architect       ← 新功能/重構時啟動；技術邊界爭議的仲裁者
├── backend         ← 實作核心邏輯與共用 API client，收到真實錯誤後修改
├── frontend        ← 實作 UI 層，可呼叫既有 client，收到真實錯誤後修改
├── tester          ← 撰寫並實際執行測試，逐條驗證規格書驗收條件
└── reviewer        ← 直接修改問題並重跑測試，留下修改紀錄
```

在 Claude Code 中使用 `.claude/agents/` 定義角色；在 Antigravity (`agy`) / 通用 Agent 中使用 `.agents/skills/` 定義角色。

## 派工規則

| 任務類型 | 委派順序 |
|---------|---------|
| 新功能 / 重構 | product-manager → ui-designer（涉及介面）→ architect → backend（+ frontend）→ tester → reviewer |
| Bug fix | backend 或 frontend → tester → reviewer |
| 純 UI 改動 | ui-designer（需調整規範時）→ frontend → reviewer |
| 需求 / 業務規則調整 | product-manager → backend → tester → reviewer |
| 安全疑慮 | reviewer（直接） |

順序不是單向的：tester 測試失敗時，Tech Lead 會把完整失敗輸出帶回 backend/frontend 修正，
循環直到全數通過才進 reviewer；tester 發現規格缺漏時回流 product-manager 補規格；
reviewer 修改程式碼後也必須重跑測試確認綠燈才結案。

## 文件驅動

規格與規範是團隊的單一事實來源（single source of truth）：

- **`docs/prd/PRD.md`** — 產品需求總綱：核心流程、功能總覽、全局紅線（product-manager 維護）
- **`docs/specs/`** — 功能規格書，一功能一檔，含業務規則與驗收條件（product-manager 撰寫，模板：`_template.md`）
- **`docs/design/web-design-guideline.md`** — Web 設計規範：色彩、字級、元件、佈局、三態定義（ui-designer 維護）

工程角色不猜規格：規格模糊就回流補規格；規範不足就先補規範，不做一次性特例。

## 協作機制

- **跨角色協商**：角色遇到職責邊界模糊時回報「立場 + 理由」，Tech Lead 居中傳話（最多 2 回合），
  無共識時依類型仲裁——需求/產品方向由 product-manager、技術歸屬由 architect、其餘由 Tech Lead，
  結果記入 `.claude/logs/decisions.md`，之後同類爭議直接沿用前例。
- **Tech Lead 先行調整**：typo 級的小修改 Tech Lead 可先動手，標記待確認，
  由負責角色在下次委派時確認並補 log，每筆都記入 `decisions.md`。
- **共享記憶**：`.claude/logs/` 是團隊的共享記憶——7 個角色各有一份執行紀錄，
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

> 想開發遊戲專案？使用遊戲專用版模板 [agent-team-game](https://github.com/Bright0505/agent-team-game)（同一套協作機制，角色換成 game-designer / gameplay / client 等遊戲分工）。

---

## 使用方式

直接向 AI（Tech Lead）描述您的任務，它會自主依序委派角色：

> 「幫我設計並實作會員點數折抵功能」

Tech Lead 判斷這是新功能，會依序委派 product-manager（規格書 + 驗收條件）→ ui-designer（折抵介面 wireframe）→ architect（模組與介面）→ backend（點數邏輯）→ frontend（介面實作）→ tester（驗收測試）→ reviewer（把關），每個角色完成後會把紀錄附加至 `.claude/logs/{role}.md`。

---

## 檔案結構

```
agent-team/
├── CLAUDE.md              ← Claude Code 協調與專案規則
├── AGENTS.md              ← Tool-agnostic/Antigravity 協調與專案規則
├── README.md
├── .gitignore
├── docs/
│   ├── prd/
│   │   └── PRD.md         ← 產品需求總綱（product-manager 維護）
│   ├── specs/
│   │   └── _template.md   ← 功能規格書模板（一功能一檔）
│   ├── design/
│   │   └── web-design-guideline.md  ← Web 設計規範（ui-designer 維護）
│   └── design-discussion-2026-07-03.md   ← 團隊設計的討論與決策紀錄
├── .agents/               ← Antigravity / 通用 Agent 設定
│   ├── rules/             ← 常駐規則（tech-lead.md）
│   └── skills/            ← 7 個角色 Skill 定義（含 SKILL.md）
└── .claude/               ← Claude Code 設定及團隊日誌
    ├── settings.json      ← 泛用權限白名單
    ├── agents/            ← 7 個 subagent 定義
    │   ├── product-manager.md
    │   ├── ui-designer.md
    │   ├── architect.md
    │   ├── backend.md
    │   ├── frontend.md
    │   ├── tester.md
    │   └── reviewer.md
    └── logs/              ← 團隊共享記憶（各角色紀錄 + 跨角色共識，Claude Code 與 agy 共用）
        ├── product-manager.md
        ├── ui-designer.md
        ├── architect.md
        ├── backend.md
        ├── frontend.md
        ├── tester.md
        ├── reviewer.md
        └── decisions.md   ← 邊界仲裁、先行調整、重大取捨
```
