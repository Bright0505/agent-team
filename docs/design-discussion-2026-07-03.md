# agent-team 設計討論紀錄 — 2026-07-03

本文件記錄一次完整的團隊設計審核與討論：先對 agent-team 模板做整體審核，修正 5 個必要問題；
再針對 5 項建議改進逐一討論，形成最終設計。之後對團隊機制有疑問時，先回來查這份文件。

---

## 一、審核發現的必要修正（已完成）

| # | 問題 | 修正 |
|---|------|------|
| 1 | setup.sh 注入的全域指示寫 `team-*`，但 subagent 名稱來自 frontmatter `name:`，放進子目錄不會加前綴，照指示會找不到 agent | 修正名稱（後續討論中全域模式整個移除，此問題不復存在） |
| 2 | 通用名稱（backend、frontend）裝到全域有撞名風險 | 同上，全域模式移除後不復存在 |
| 3 | 派工規則是單向的，tester 紅燈後的處理只存在腦中 | CLAUDE.md 新增「紅綠燈迴圈」：失敗輸出原文帶回 backend/frontend 重派，全綠才進 reviewer |
| 4 | tester 有 Bash 但沒被要求實際執行測試 | tester 原則加「寫完必須實際執行、不允許只寫不跑」，紀錄格式加「測試結果」欄位 |
| 5 | reviewer 直接修改程式碼卻沒人驗證它的修改 | reviewer 原則加「每次修改後必須重跑相關測試，紅燈不得結案」 |

**核心觀念**：3、4、5 是同一件事的三個面向——**紅綠燈訊號必須在流程中流動**，
寫測試的人要跑測試、改程式的人要看訊號、訊號要能把工作帶回上游。

---

## 二、建議改進的討論與最終設計

### 1. backend / frontend 的 API 邊界 → 跨角色協商機制

**原始問題**：frontend「不寫 API client」但前端呼叫 API 的邏輯很難完全切給 backend，會互踢皮球。

**討論結論**：
- 預設邊界明文化：backend 負責共用 API client 模組（含認證、錯誤處理），frontend 可**呼叫**既有 client 並處理 UI 狀態
- 邊界模糊時走協商：角色**不默默做掉也不默默拒絕**，輸出「立場 + 理由」回報 Tech Lead
- subagent 之間不能直接對話，Tech Lead 用 **SendMessage 延續既有 agent** 傳話（保留 context，不冷啟動）
- **回合上限 2 回合**，避免無限互踢；無共識時新功能情境由 architect 仲裁，其餘由 Tech Lead 裁決
- 裁決記入 `decisions.md`，同類爭議之後直接沿用前例

**設計原則**：討論是例外處理，不是常態——所以預設邊界規則仍然要有。

### 2. Tech Lead 完全不寫 code 太絕對 → 先行調整 + 角色確認

**原始問題**：改一行 typo 也要起一個 subagent，成本太高。

**討論結論**（使用者提出，優於原本的「豁免」方案，因為保留了角色所有權與紀錄鏈）：
- 單檔、明顯、非邏輯性的小修改，Tech Lead 可先動手，標記「待確認」
- 確認時機分兩種：近期會委派該角色 → diff 附在下次委派 prompt 順便確認（零額外成本）；
  獨立緊急修改 → 即刻起輕量確認
- 每筆先行調整記入 `decisions.md`，避免「沒有任何角色知道這段 code 被改過」的黑洞

### 3. logs 的定位 → 團隊共享記憶

**原始問題**：全域模式的 log seed 步驟多餘且有 `cp -r` 巢狀 bug。

**討論結論**：使用者真正的意圖是 logs 要成為**相互討論的依據**。最終設計三層：
- 保留 5 個角色各自的 log（執行紀錄）
- 新增 `.claude/logs/decisions.md`：跨角色共識——邊界仲裁、Tech Lead 先行調整、architect 重大取捨，由 Tech Lead 寫入
- 委派規則補強：Tech Lead 委派時附相關 log 摘要與 decisions.md 前例；角色開工前先查前例

**效果**：同一個爭議不會每次重新吵，有前例直接沿用。

### 4. 權限白名單 → 泛用版 `.claude/settings.json`

**原則**：測試 / 建置 / 檢查類放行，唯讀 git 放行，會改外部狀態的不放。

- 放行：`npm test`、`npm run test/build/lint/typecheck`、`npx vitest/jest/tsc/eslint`、`npm install/ci`、`git status/diff/log/show`
- 刻意不放：`git commit`、`git push`、`rm`、部署類——維持人工把關
- 後續可在實際專案用 `/fewer-permission-prompts` 依真實使用紀錄微調

### 5. 全域模式 → 移除，定位為純模板

**討論結論**：使用者不需要全域安裝，預期用法是「以這個專案為模板直接開新專案開發」。

- 刪除 `setup.sh`、README 移除模式 B
- 順帶消除了必要修正 1、2 的名稱問題根源
- README 改推薦 GitHub template repository（`gh repo create my-project --template ...`），
  次選 clone + `rm -rf .git`

---

## 三、最終機制總覽

```
使用者描述任務
    │
Tech Lead 判斷類型、查 decisions.md 前例
    │
依派工表委派（prompt 帶：任務、根目錄、檔案、前角色摘要、log 摘要）
    │
角色執行 ──遇邊界爭議──→ 立場+理由 → Tech Lead 傳話（≤2回合）→ 仲裁 → decisions.md
    │
tester 實跑測試 ──紅燈──→ 失敗原文帶回 backend/frontend（循環到全綠）
    │
reviewer 直接修問題 + 重跑測試（紅燈不結案）
    │
各角色 append log → Tech Lead 整合回報
```

留痕的三個去處：`logs/{role}.md`（各角色執行紀錄）、`logs/decisions.md`（跨角色共識）、
本 `docs/` 目錄（設計層級的討論紀錄）。
