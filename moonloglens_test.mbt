///|
fn entry_ok(input : String) -> @moonloglens.LogEntry {
  match @moonloglens.parse_line(input) {
    Ok(entry) => entry
    Err(err) => abort("unexpected log error: " + @moonloglens.format_error(err))
  }
}

///|
fn query_ok(input : String) -> @moonloglens.Query {
  match @moonloglens.parse_query(input) {
    Ok(query) => query
    Err(err) =>
      abort("unexpected query error: " + @moonloglens.format_error(err))
  }
}

///|
fn value_ok(entry : @moonloglens.LogEntry, key : String) -> String {
  match @moonloglens.get(entry, key) {
    Some(value) => value
    None => abort("missing field: " + key)
  }
}

///|
test "parse logfmt fields and quoted values" {
  let entry = entry_ok(
    "ts=2026-06-04T10:00:00Z level=ERROR service=api msg=\"request timeout\" trace_id=abc123",
  )
  assert_eq(value_ok(entry, "level"), "ERROR")
  assert_eq(value_ok(entry, "service"), "api")
  assert_eq(value_ok(entry, "msg"), "request timeout")
  assert_eq(value_ok(entry, "trace_id"), "abc123")
  assert_eq(@moonloglens.message(entry), "request timeout")
}

///|
test "parse escaped characters inside quoted values" {
  let entry = entry_ok("level=INFO service=worker msg=\"started \\\"job\\\"\"")
  assert_eq(value_ok(entry, "msg"), "started \"job\"")
}

///|
test "parse multiple lines and keep error line" {
  match
    @moonloglens.parse_lines(
      "level=INFO service=api msg=ok\nlevel=ERROR service=api msg=\"broken",
    ) {
    Err(err) =>
      assert_eq(
        @moonloglens.format_error(err),
        "line 2, column 29: unterminated quoted value",
      )
    Ok(_) => abort("expected parse_lines error")
  }
}

///|
test "reports missing key and value" {
  match @moonloglens.parse_line("level=INFO =broken") {
    Err(err) =>
      assert_eq(
        @moonloglens.format_error(err),
        "line 1, column 12: missing key",
      )
    Ok(_) => abort("expected missing key error")
  }
  match @moonloglens.parse_line("level=INFO service=") {
    Err(err) =>
      assert_eq(
        @moonloglens.format_error(err),
        "line 1, column 20: missing value for key service",
      )
    Ok(_) => abort("expected missing value error")
  }
}

///|
test "query matches fields text and presence" {
  let entry = entry_ok(
    "level=ERROR service=api msg=\"request timeout\" trace_id=abc123",
  )
  let query = query_ok("level:ERROR service:api text:\"timeout\" has:trace_id")
  assert_true(@moonloglens.matches(entry, query))
  let miss = query_ok("level:ERROR service:worker")
  assert_false(@moonloglens.matches(entry, miss))
}

///|
test "filter entries with query" {
  let entries = match
    @moonloglens.parse_lines(
      "level=INFO service=api msg=started\nlevel=ERROR service=api msg=\"request timeout\"\nlevel=ERROR service=worker msg=retry",
    ) {
    Ok(entries) => entries
    Err(err) =>
      abort("unexpected parse error: " + @moonloglens.format_error(err))
  }
  let found = @moonloglens.filter(entries, query_ok("level:ERROR service:api"))
  assert_eq(found.length(), 1)
  assert_eq(value_ok(found[0], "msg"), "request timeout")
}

///|
test "count entries by field" {
  let entries = match
    @moonloglens.parse_lines(
      "level=INFO service=api msg=started\nlevel=ERROR service=api msg=timeout\nlevel=ERROR service=worker msg=retry",
    ) {
    Ok(entries) => entries
    Err(err) =>
      abort("unexpected parse error: " + @moonloglens.format_error(err))
  }
  let counts = @moonloglens.count_by(entries, "level")
  assert_eq(counts.length(), 2)
  assert_eq(counts[0].value, "INFO")
  assert_eq(counts[0].count, 1)
  assert_eq(counts[1].value, "ERROR")
  assert_eq(counts[1].count, 2)
}
