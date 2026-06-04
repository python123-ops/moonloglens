# python123/moonloglens

MoonLogLens is a lightweight structured log parser, query engine, and
aggregation helper for MoonBit.

The project targets a practical gap in the MoonBit ecosystem: developers often
need to inspect log streams, filter incidents by fields, and summarize service
behavior without a full observability stack. MoonLogLens focuses on a compact,
dependency-free core that can be tested, published, and reused by other MoonBit
projects.

## Features

- Parse logfmt-style entries such as
  `ts=2026-06-04T10:00:00Z level=ERROR service=api msg="request timeout"`.
- Support quoted values, escaped characters, spaces inside values, and
  line/column diagnostics.
- Parse multi-line log text into structured entries.
- Filter entries with a small query language:
  `level:ERROR service:api text:"timeout" has:trace_id`.
- Aggregate entries by a field with `count_by(entries, "service")`.
- Provide a deterministic CLI demo through `moon run cmd/main`.

## Quick Start

```bash
moon test
moon run cmd/main
```

Example output:

```text
MoonLogLens demo
entries=3
query=level:ERROR service:api
matches=1
first_msg=request timeout
--- count_by(service) ---
api=2
worker=1
```

## API Example

```mbt nocheck
///|
test "find api errors" {
  let entries = match @moonloglens.parse_lines(
    "level=INFO service=api msg=started\nlevel=ERROR service=api msg=\"request timeout\"",
  ) {
    Ok(entries) => entries
    Err(err) => fail(@moonloglens.format_error(err))
  }
  let query = match @moonloglens.parse_query("level:ERROR service:api") {
    Ok(query) => query
    Err(err) => fail(@moonloglens.format_error(err))
  }
  let found = @moonloglens.filter(entries, query)
  assert_eq(found.length(), 1)
}
```

Public API:

- `parse_line(input : String) -> Result[LogEntry, LogError]`
- `parse_lines(input : String) -> Result[Array[LogEntry], LogError]`
- `parse_query(input : String) -> Result[Query, LogError]`
- `matches(entry : LogEntry, query : Query) -> Bool`
- `filter(entries : Array[LogEntry], query : Query) -> Array[LogEntry]`
- `count_by(entries : Array[LogEntry], key : String) -> Array[CountBucket]`
- `get(entry : LogEntry, key : String) -> String?`
- `message(entry : LogEntry) -> String`
- `format_error(err : LogError) -> String`

## Design

MoonLogLens intentionally keeps the first version small:

- The parser scans each line once and builds `Array[LogField]` values.
- The query parser supports field equality, text containment, and field
  existence checks.
- Query clauses are combined with AND semantics.
- Aggregation preserves first-seen bucket order, which makes CLI output stable.
- No file I/O, background services, external storage, or third-party MoonBit
  packages are required.

This scope makes the package suitable as a contest entry and as a foundation
for future work such as streaming ingestion, richer query syntax, and
observability dashboards.

## Competition Materials

- Project proposal: `docs/competition/proposal.md`
- Acceptance checklist: `docs/competition/acceptance-checklist.md`
- Submission guide: `docs/competition/submission-guide.md`
- Design note: `docs/superpowers/specs/2026-06-04-moonloglens-design.md`
- Implementation plan: `docs/superpowers/plans/2026-06-04-moonloglens.md`

## Development

```bash
moon info
moon fmt
moon test
moon run cmd/main
```

## License

Apache-2.0
