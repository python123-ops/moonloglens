# MoonDepSolve Design

## Goal

MoonDepSolve provides a compact MoonBit dependency resolution core for package
ecosystem tooling. It handles semantic versions, version ranges, transitive
dependencies, deterministic selection, and human-readable conflict diagnosis.

## Data Model

- `Version` stores major, minor, patch, and optional prerelease text.
- `VersionReq` stores the original range text plus normalized comparators.
- `Dependency` connects a package name with a version requirement.
- `PackageVersion` stores one concrete package release and its dependencies.
- `Registry` is an in-memory package index.
- `Resolution` is an ordered list of selected package versions.
- `DepError` represents parse errors, missing packages, no matching versions,
  and version conflicts.

## Resolution Strategy

The resolver starts with root dependencies, expands one pending dependency at a
time, and selects the highest compatible package version from the registry. If a
selected package is encountered again, the new requirement must match the
selected version. When it does not, the resolver returns a conflict message with
the dependency path that introduced the incompatible requirement.

The implementation uses arrays instead of maps to avoid external dependencies
and keep the first version easy to inspect. The public API stays small enough to
serve as a stable base for later lockfile, package-index, and build-planning
extensions.
