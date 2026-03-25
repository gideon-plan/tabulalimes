## ingest.nim -- Extraction -> chunking -> embedding -> limes store.
{.experimental: "strict_funcs".}
import std/tables
import basis/code/choice, extract

type
  EmbedFn* = proc(text: string): Choice[seq[float32]] {.raises: [].}
  StoreFn* = proc(embedding: seq[float32], text: string, metadata: Table[string, string]): Choice[string] {.raises: [].}

proc ingest_pages*(pages: seq[PageText], embed_fn: EmbedFn, store_fn: StoreFn,
                   source: string): Choice[int] =
  var count = 0
  for page in pages:
    let paragraphs = split_paragraphs(page)
    for i, para in paragraphs:
      let emb = embed_fn(para)
      if emb.is_bad: return bad[int](emb.err)
      var meta: Table[string, string]
      meta["source"] = source
      meta["page"] = $page.page
      meta["paragraph"] = $i
      let id = store_fn(emb.val, para, meta)
      if id.is_bad: return bad[int](id.err)
      inc count
  good(count)
