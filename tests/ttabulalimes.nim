{.experimental: "strict_funcs".}
import std/[unittest, tables]
import tabulalimes

suite "extract":
  test "split paragraphs":
    let page = PageText(page: 1, text: "First paragraph.\n\nSecond paragraph.\n\nThird.")
    let paras = split_paragraphs(page)
    check paras.len == 3
    check paras[0] == "First paragraph."

suite "ingest":
  test "ingest pages with mock":
    let mock_embed: EmbedFn = proc(t: string): Result[seq[float32], BridgeError] {.raises: [].} =
      Result[seq[float32], BridgeError].good(@[1.0'f32])
    let mock_store: StoreFn = proc(e: seq[float32], t: string, m: Table[string, string]): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("id1")
    let pages = @[PageText(page: 1, text: "Hello world.\n\nSecond paragraph.")]
    let r = ingest_pages(pages, mock_embed, mock_store, "test.pdf")
    check r.is_good
    check r.val == 2
