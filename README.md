# agent-team

一個可重複使用的 Claude 開發團隊**專案模板**。把 5 個角色定義成 Claude Code 的 **subagents**，Claude 以 Tech Lead 身份依任務類型自主委派，每個角色留下各自的紀錄供未來參考。

---

## 團隊結構

```
Claude（Tech Lead / 協調者）
│
├── architect     ← 只在新功能 / 重構時啟動；邊界爭議的仲裁者（model: opus）
├── backend       ← 實作核心邏輯與共用 API client，收到真實錯誤後修改（model: sonnet）
├── frontend      ← 實作 UI 層，可呼叫既有 client，收到真實錯誤後修改（model: sonnet）
├── tester        ← 撰寫並實際執行測試，找邊界案例（model: sonnet）
└── reviewer      ← 直接修改問題並重跑測試，留下修改紀錄（model: opus）
```

各角色是真正的 subagent（`.claude/agents/`），有獨立 context、各自的工具與模型。

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

clone 下來的 `.claude/agents/` 正好落在專案根，Claude Code 一開工就自動發現；
根目錄 `CLAUDE.md` 上半部是協調規則（沿用），下半部留白給你填專案專屬規則。

`.claude/settings.json` 內建一份泛用的權限白名單（測試 / 建置 / lint / 唯讀 git），
讓流水線不會被權限提示打斷；`git commit`、`git push`、部署類指令刻意不放行，維持人工把關。
在實際專案跑一陣子後，可用 `/fewer-permission-prompts` 依真實使用紀錄微調。

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
├── .gitignore
├── docs/
│   └── design-discussion-2026-07-03.md   ← 團隊設計的討論與決策紀錄
└── .claude/
    ├── settings.json     ← 泛用權限白名單
    ├── agents/           ← 5 個 subagent 定義（含 frontmatter）
    │   ├── architect.md
    │   ├── backend.md
    │   ├── frontend.md
    │   ├── tester.md
    │   └── reviewer.md
    └── logs/             ← 團隊共享記憶（各角色紀錄 + 跨角色共識）
        ├── architect.md
        ├── backend.md
        ├── frontend.md
        ├── tester.md
        ├── reviewer.md
        └── decisions.md  ← 邊界仲裁、先行調整、重大取捨
```
