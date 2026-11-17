import { validateImageUpload } from '@/lib/upload'
import { BUCKETS } from '@/lib/project'
import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const file = formData.get('file') as File | null
    const notebookId = formData.get('notebook_id') as string | null

    if (!file || !notebookId) {
      return NextResponse.json({ error: 'file and notebook_id required' }, { status: 400 })
    }
    const uploadError = validateImageUpload(file)
    if (uploadError) {
      return NextResponse.json({ error: uploadError }, { status: 400 })
    }

    const ext = file.name.split('.').pop() ?? 'jpg'
    const path = `${notebookId}/${Date.now()}.${ext}`

    const supabase = createClient()
    const { data, error } = await supabase.storage
      .from(BUCKETS.receipts)
      .upload(path, file, { upsert: true, contentType: file.type })

    if (error) return NextResponse.json({ error: error.message }, { status: 500 })

    const { data: urlData } = supabase.storage.from(BUCKETS.receipts).getPublicUrl(data.path)
    return NextResponse.json({ url: urlData.publicUrl })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
