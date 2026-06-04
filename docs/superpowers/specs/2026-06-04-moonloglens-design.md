# MoonLogLens Design

## Summary

MoonLogLens is a lightweight MoonBit library for structured log parsing,
field-based querying, and simple aggregation. It is positioned as a small
foundation for log inspection and incident triage rather than as a general data
format parser.

The project targets logfmt-style text because it is common in backend services,
easy to read by humans, and compact enough for a contest entry to implement
well. The first version focuses on deterministic parsing, precise diagnostics,
query filtering, aggregation, tests, documentation, and a CLI demo.

## Goals

1. Parse one log line into `LogEntry` with ordered `LogField` values.
2. Parse multi-line log text and preserve the failing line number in errors.
3. Support quoted values, escaped characters, and spaces inside quoted values.
4. Provide a small query language with field equality, text containment, and
   field-existence checks.
5. Aggregate entries by field while preserving first-seen bucket order.
6. Keep the implementation dependency-free and suitable for publication as a
   MoonBit ecosystem package.

## Public API

- `LogField`: key-value pair.
- `LogEntry`: parsed entry containing ordered fields.
- `QueryClause`: field equality, text containment, or field existence.
- `Query`: AND-combined list of query clauses.
- `CountBucket`: aggregation result.
- `LogError`: parse and query diagnostics with line/column positions.

The core functions are `parse_line`, `parse_lines`, `parse_query`, `matches`,
`filter`, `count_by`, `get`, `message`, and `format_error`.

## Architecture

The parser is a single-pass scanner over characters. It reads `key=value`
pairs separated by spaces or tabs, handles quoted values with backslash escapes,
and reports missing keys, missing separators, missing values, and unterminated
quotes.

The query parser uses a matching scanner for tokens of the form `name:value`.
`text:value` checks whether any field value contains the term, `has:key` checks
for field presence, and other names become exact field-equality checks.

Aggregation uses arrays instead of a map so the package remains dependency-free
and keeps deterministic first-seen ordering for examples and tests.

## Validation

The blackbox tests cover normal parsing, quoted values, escaped quotes,
multi-line diagnostics, malformed input, query matching, filtering, and
aggregation. The CLI demo exercises the same public APIs on an embedded sample.
