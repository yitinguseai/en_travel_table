/** 固定專案身分；須與 Supabase 建表 SQL、Storage 及工作流程同步。 */
export const PROJECT_CODE = 'YT001' as const
export const PROJECT_NAME = '旅行分帳' as const

const prefix = PROJECT_CODE.toLowerCase() as Lowercase<typeof PROJECT_CODE>

export const TABLES = {
  notebooks: `${prefix}_notebooks`,
  members: `${prefix}_members`,
  currencies: `${prefix}_currencies`,
  expenses: `${prefix}_expenses`,
  expense_splits: `${prefix}_expense_splits`,
  settlement_items: `${prefix}_settlement_items`,
  collection_info: `${prefix}_collection_info`,
} as const

export const BUCKETS = {
  receipts: `${prefix}-receipts`,
  proofs: `${prefix}-proofs`,
  qrcodes: `${prefix}-qrcodes`,
} as const
