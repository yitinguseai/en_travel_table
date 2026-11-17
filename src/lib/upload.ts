/** 與 YT001 三個 Supabase Storage buckets 的限制保持一致。 */
export const IMAGE_UPLOAD_MAX_BYTES = 2 * 1024 * 1024
export const IMAGE_UPLOAD_ACCEPT = 'image/*'
export const IMAGE_UPLOAD_HINT = '僅限圖片，每個檔案最大 2 MB'

export function validateImageUpload(file: Pick<File, 'type' | 'size'>): string | null {
  if (!file.type.startsWith('image/')) return '僅支援圖片格式'
  if (file.size > IMAGE_UPLOAD_MAX_BYTES) return '檔案超過 2 MB 上限'
  return null
}
