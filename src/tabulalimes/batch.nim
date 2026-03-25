## batch.nim -- Batch ingest directory of PDFs.
{.experimental: "strict_funcs".}
import std/[os, strutils]
import basis/code/choice, extract, ingest

type
  BatchResult* = object
    files_processed*: int
    chunks_stored*: int
    errors*: seq[string]

proc batch_ingest*(dir: string, extract_fn: ExtractFn, embed_fn: EmbedFn,
                   store_fn: StoreFn): BatchResult =
  for entry in walkDir(dir):
    if entry.kind == pcFile and entry.path.endsWith(".pdf"):
      let pages = extract_fn(entry.path)
      if pages.is_bad:
        result.errors.add(entry.path & ": " & pages.err.msg)
        continue
      let count = ingest_pages(pages.val, embed_fn, store_fn, entry.path)
      if count.is_bad:
        result.errors.add(entry.path & ": " & count.err.msg)
        continue
      result.chunks_stored += count.val
      inc result.files_processed
