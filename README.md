# 旅行分帳

由 [yitinguseai](https://github.com/yitinguseai) 維護。
儲存庫：https://github.com/yitinguseai/en_travel_table

## 網站功能

- 不需註冊即可建立記帳本，透過連結分享給旅伴。
- 管理成員、幣別與匯率，記錄付款人、收據及私人／共享費用。
- 支援平均、自訂金額與比例分攤。
- 計算收支與轉帳清單，匯出 Excel 結算明細。
- 管理收款帳號、QR Code、匯款憑證與付款確認狀態。
- 建立記帳本時透過 Resend 寄出連結。

技術：Next.js 16、React 19、TypeScript、Tailwind CSS 4、Supabase 與 Resend。

## 本機啟動

```bash
cd /Users/changyiting/Documents/分攤網站/en_travel_table
npm ci
cp .env.example .env.local
```

填入自己的 Supabase 與 Resend 設定，再執行 `npm run dev`，開啟 http://localhost:3000。
`.env.local` 不會提交到 GitHub。

## 更新到 GitHub

本機已設定提交者為 `yitinguseai <yiting.useai@gmail.com>`。
`origin` 是 `https://github.com/yitinguseai/en_travel_table.git`，也是預設推送目標；`main` 追蹤 `origin/main`。
`upstream` 保留原始來源，本機已停用對它的推送。

修改程式後需提交並推送，GitHub 才會更新：

```bash
git add <要提交的檔案>
git commit -m "說明這次修改"
git push
```

推送需使用有此儲存庫寫入權限的 GitHub 憑證。本機 Git 設定不隨 clone 傳遞，換電腦時需重新設定提交者。

## 雲端服務設定

GitHub、Supabase、Resend 與部署平台分開管理。Fork 不會轉移金鑰或雲端資源。

1. 在自己的 Supabase 專案檢查並執行 `supabase-schema.sql`，建立資料表與公開 Storage buckets：`tp-receipts`、`tp-proofs`、`tp-qrcodes`。正式啟用前需核對資料庫結構與程式使用的欄位。
2. 在 `.env.local` 與部署平台設定 `.env.example` 列出的變數；service role key 與 Resend API key 僅供伺服器使用。
3. 目前寄件者為 Resend 測試地址 `onboarding@resend.dev`。正式寄送需驗證自己的寄件網域並調整寄件者。
4. 部署平台需連接 `yitinguseai/en_travel_table` 的 `main` 分支並設定環境變數；推送是否自動部署由平台設定決定。
5. 保活工作流程在 `.github/workflows/supabase-keepalive.yml`。在自己的 GitHub 儲存庫 Actions secrets 設定 `SUPABASE_URL` 與 `SUPABASE_ANON_KEY`，並在 fork 啟用工作流程。
6. 14 天未開啟的記帳本自動刪除需另行啟用 Supabase `pg_cron`；SQL 檔提供設定範例。

目前儲存庫未包含實際服務金鑰或部署專案綁定。
