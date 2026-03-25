## extract.nim -- PDF text extraction via tabula, page-level and paragraph-level.
{.experimental: "strict_funcs".}
import std/[strutils, tables]
import basis/code/choice

type
  PageText* = object
    page*: int
    text*: string
    metadata*: Table[string, string]

  ExtractFn* = proc(pdf_path: string): Choice[seq[PageText]] {.raises: [].}

proc extract_pages*(pdf_path: string, extract_fn: ExtractFn): Choice[seq[PageText]] =
  extract_fn(pdf_path)

proc split_paragraphs*(page: PageText): seq[string] =
  for p in page.text.split("\n\n"):
    let trimmed = p.strip()
    if trimmed.len > 0: result.add(trimmed)
