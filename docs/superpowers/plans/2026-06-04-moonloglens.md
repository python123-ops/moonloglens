# MoonLogLens Implementation Plan

## Summary

Rework the former rejected topic into MoonLogLens, a structured log parser and
query helper for MoonBit. Preserve Git history, remove old topic traces, and
ship updated code, tests, CLI, README, and competition materials.

## Implementation Steps

1. Replace the old tests with MoonLogLens blackbox tests for parsing,
   diagnostics, query matching, filtering, and aggregation.
2. Replace the root package implementation with logfmt parsing, query parsing,
   matching, filtering, field access, message access, aggregation, and error
   formatting.
3. Update `moon.mod`, package imports, and CLI demo to use
   `python123/moonloglens`.
4. Rewrite README and competition docs around the structured-log topic.
5. Regenerate the project application PDF and editable DOCX.
6. Run `moon info`, `moon fmt`, `moon test`, `moon run cmd/main`, README mode
   checks, and old-topic residue checks.
7. Commit and push the updated repository to GitLink.

## Acceptance Criteria

- `moon test` passes without warnings.
- `moon run cmd/main` prints the MoonLogLens demo.
- `README.md` is a normal tracked file with mode `100644`.
- Public docs no longer describe the old rejected topic.
- The repository contains a new MoonLogLens application PDF.
- GitLink remote receives the updated history with more than 10 commits.
