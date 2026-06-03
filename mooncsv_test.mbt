///|
fn parse_ok(input : String) -> @mooncsv.Document {
  match @mooncsv.parse(input) {
    Ok(doc) => doc
    Err(err) => abort("unexpected parse error: " + @mooncsv.format_error(err))
  }
}

///|
fn value_ok(result : Result[String, @mooncsv.CsvError]) -> String {
  match result {
    Ok(value) => value
    Err(err) => abort("unexpected csv error: " + @mooncsv.format_error(err))
  }
}

///|
test "parse plain rows" {
  let doc = parse_ok("name,score\nAda,98\nMoonBit,100")
  assert_eq(doc.rows.length(), 3)
  assert_eq(doc.rows[0][0], "name")
  assert_eq(doc.rows[1][0], "Ada")
  assert_eq(doc.rows[2][1], "100")
}

///|
test "parse quoted fields and escaped quotes" {
  let doc = parse_ok(
    "name,note\nAda,\"hello, \"\"MoonBit\"\"\"\nBob,\"line1\nline2\"",
  )
  assert_eq(doc.rows.length(), 3)
  assert_eq(doc.rows[1][1], "hello, \"MoonBit\"")
  assert_eq(doc.rows[2][1], "line1\nline2")
}

///|
test "parse crlf and trailing empty field" {
  let doc = parse_ok("a,b,c\r\n1,2,\r\n")
  assert_eq(doc.rows.length(), 2)
  assert_eq(doc.rows[1].length(), 3)
  assert_eq(doc.rows[1][2], "")
}

///|
test "stringify quotes only when needed" {
  let doc = @mooncsv.Document::{
    rows: [["name", "note"], ["Ada", "hello, \"MoonBit\"\nline2"]],
  }
  assert_eq(
    @mooncsv.stringify(doc),
    "name,note\nAda,\"hello, \"\"MoonBit\"\"\nline2\"",
  )
}

///|
test "validate rectangular rows" {
  let ok = @mooncsv.Document::{ rows: [["a", "b"], ["1", "2"]] }
  guard @mooncsv.validate_rectangular(ok) is Ok(_) else {
    fail("expected rectangular document")
  }
  let bad = @mooncsv.Document::{ rows: [["a", "b"], ["1"]] }
  match @mooncsv.validate_rectangular(bad) {
    Err(err) =>
      assert_eq(@mooncsv.format_error(err), "row 2 has 1 columns, expected 2")
    Ok(_) => abort("expected rectangular validation error")
  }
}

///|
test "lookup cells by header" {
  let doc = parse_ok("name,score\nAda,98\nMoonBit,100")
  assert_eq(value_ok(@mooncsv.get_by_header(doc, 0, "score")), "98")
  assert_eq(value_ok(@mooncsv.get_by_header(doc, 1, "name")), "MoonBit")
  match @mooncsv.get_by_header(doc, 0, "missing") {
    Err(err) => assert_eq(@mooncsv.format_error(err), "missing header: missing")
    Ok(_) => abort("expected missing header error")
  }
}

///|
test "summarize document" {
  let doc = parse_ok("name,score\nAda,98\nMoonBit,100")
  assert_eq(@mooncsv.summarize(doc), "rows=3, columns=2, headers=name|score")
}

///|
test "reports unterminated quoted field" {
  match @mooncsv.parse("name\n\"Ada") {
    Err(err) =>
      assert_eq(
        @mooncsv.format_error(err),
        "line 2, column 1: unterminated quoted field",
      )
    Ok(_) => abort("expected unterminated quote error")
  }
}

///|
test "reports bare quote" {
  match @mooncsv.parse("a,b\nx,y\"z") {
    Err(err) =>
      assert_eq(@mooncsv.format_error(err), "line 2, column 4: bare quote")
    Ok(_) => abort("expected bare quote error")
  }
}
