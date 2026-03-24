## ingest.nim -- Extraction -> chunking -> embedding -> limes store.
{.experimental: "strict_funcs".}
import std/tables
import lattice, extract

type
  EmbedFn* = proc(text: string): Result[seq[float32], BridgeError] {.raises: [].}
  StoreFn* = proc(embedding: seq[float32], text: string, metadata: Table[string, string]): Result[string, BridgeError] {.raises: [].}

proc ingest_pages*(pages: seq[PageText], embed_fn: EmbedFn, store_fn: StoreFn,
                   source: string): Result[int, BridgeError] =
  var count = 0
  for page in pages:
    let paragraphs = split_paragraphs(page)
    for i, para in paragraphs:
      let emb = embed_fn(para)
      if emb.is_bad: return Result[int, BridgeError].bad(emb.err)
      var meta: Table[string, string]
      meta["source"] = source
      meta["page"] = $page.page
      meta["paragraph"] = $i
      let id = store_fn(emb.val, para, meta)
      if id.is_bad: return Result[int, BridgeError].bad(id.err)
      inc count
  Result[int, BridgeError].good(count)
