# MoonDepSolve

MoonDepSolve is a small MoonBit library for semantic version parsing, version
range matching, and deterministic dependency resolution. It is designed as a
basic package-ecosystem component for MoonBit tooling, build planning, package
auditing, and dependency conflict diagnosis.

Current public repositories:

- GitLink: <https://gitlink.org.cn/python123/moonloglens>
- GitHub: <https://github.com/python123-ops/moonloglens>

The repository keeps its original submission history, while the project itself
has been rebuilt as MoonDepSolve.

## Features

- Parse semantic versions such as `1.2.3` and `1.2.3-alpha.1`.
- Compare stable and prerelease versions.
- Parse version requirements:
  - exact: `1.2.3`
  - caret: `^1.2.0`
  - tilde: `~1.2.0`
  - comparator set: `>=1.0.0 <2.0.0`
  - wildcard: `1.2.x`
- Resolve transitive dependencies from an in-memory package registry.
- Select the highest compatible version deterministically.
- Report readable conflicts with dependency paths.
- Format a stable lock-style result for demos and tests.

## Public API

```moonbit
parse_version(input : String) -> Result[Version, DepError]
parse_req(input : String) -> Result[VersionReq, DepError]
matches(version : Version, req : VersionReq) -> Bool
resolve(root : Array[Dependency], registry : Registry) -> Result[Resolution, DepError]
format_error(err : DepError) -> String
format_lock(resolution : Resolution) -> String
```

## Example

```moonbit
let registry : @moondepsolve.Registry = {
  packages: [
    {
      name: "core",
      version: version("1.2.0"),
      dependencies: [],
    },
    {
      name: "http",
      version: version("0.3.4"),
      dependencies: [dependency("core", "^1.0.0")],
    },
  ],
}

match @moondepsolve.resolve([dependency("http", "~0.3.0")], registry) {
  Ok(result) => println(@moondepsolve.format_lock(result))
  Err(err) => println(@moondepsolve.format_error(err))
}
```

## Demo

```bash
moon run cmd/main
```

The demo builds a tiny package registry, resolves `appkit@1.0.0`, and prints a
stable lock-style result.

## Test

```bash
moon test
```

The test suite covers version parsing, prerelease comparison, range matching,
transitive resolution, conflict diagnosis, and lock output.

## License

Apache-2.0
