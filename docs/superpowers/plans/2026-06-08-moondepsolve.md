# MoonDepSolve Implementation Plan

## Summary

Rebuild the project as a MoonBit semantic version and dependency resolution
library. Keep the original repository history, replace the old project surface,
and prepare competition materials with effective GitLink and GitHub links.

## Key Tasks

- Rename package metadata to `python123/moondepsolve`.
- Replace the previous core library with semantic version, range, and resolver APIs.
- Add tests for version parsing, range matching, resolution, conflicts, and lock output.
- Rewrite the CLI demo around dependency resolution.
- Rewrite README and competition materials for the new topic.
- Generate a fresh PDF and DOCX application document.
- Run MoonBit verification and push to the public remotes.

## Verification

- `moon info && moon fmt`
- `moon test`
- `moon run cmd/main`
- `git ls-files -s README.md`
- residue search for old project prose
