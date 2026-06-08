///|
fn version_ok(input : String) -> @moondepsolve.Version {
  match @moondepsolve.parse_version(input) {
    Ok(version) => version
    Err(err) =>
      abort("unexpected version error: " + @moondepsolve.format_error(err))
  }
}

///|
fn req_ok(input : String) -> @moondepsolve.VersionReq {
  match @moondepsolve.parse_req(input) {
    Ok(req) => req
    Err(err) =>
      abort("unexpected requirement error: " + @moondepsolve.format_error(err))
  }
}

///|
fn dep(name : String, req : String) -> @moondepsolve.Dependency {
  { name, req: req_ok(req) }
}

///|
fn pkg(
  name : String,
  version : String,
  dependencies : Array[@moondepsolve.Dependency],
) -> @moondepsolve.PackageVersion {
  { name, version: version_ok(version), dependencies }
}

///|
fn registry(
  packages : Array[@moondepsolve.PackageVersion],
) -> @moondepsolve.Registry {
  { packages, }
}

///|
fn version_text(version : @moondepsolve.Version) -> String {
  @moondepsolve.format_version(version)
}

///|
test "parse semantic versions and reject malformed input" {
  let stable = version_ok("1.2.3")
  assert_eq(stable.major, 1)
  assert_eq(stable.minor, 2)
  assert_eq(stable.patch, 3)
  match stable.prerelease {
    None => ()
    Some(_) => abort("stable version should not have prerelease")
  }
  let pre = version_ok("1.2.3-alpha.1")
  match pre.prerelease {
    Some(value) => assert_eq(value, "alpha.1")
    None => abort("expected prerelease")
  }
  match @moondepsolve.parse_version("1.2") {
    Err(err) =>
      assert_eq(
        @moondepsolve.format_error(err),
        "invalid version '1.2': expected major.minor.patch",
      )
    Ok(_) => abort("expected malformed version to fail")
  }
}

///|
test "compare versions with prerelease ordering" {
  assert_true(
    @moondepsolve.compare_version(version_ok("1.2.4"), version_ok("1.2.3")) > 0,
  )
  assert_true(
    @moondepsolve.compare_version(
      version_ok("1.2.3-alpha.1"),
      version_ok("1.2.3"),
    ) <
    0,
  )
  assert_true(
    @moondepsolve.compare_version(
      version_ok("1.2.3-alpha.2"),
      version_ok("1.2.3-alpha.1"),
    ) >
    0,
  )
}

///|
test "match exact caret tilde comparator and wildcard ranges" {
  assert_true(@moondepsolve.matches(version_ok("1.2.3"), req_ok("1.2.3")))
  assert_true(@moondepsolve.matches(version_ok("1.8.0"), req_ok("^1.2.0")))
  assert_false(@moondepsolve.matches(version_ok("2.0.0"), req_ok("^1.2.0")))
  assert_true(@moondepsolve.matches(version_ok("1.2.9"), req_ok("~1.2.0")))
  assert_false(@moondepsolve.matches(version_ok("1.3.0"), req_ok("~1.2.0")))
  assert_true(
    @moondepsolve.matches(version_ok("1.5.0"), req_ok(">=1.0.0 <2.0.0")),
  )
  assert_false(
    @moondepsolve.matches(version_ok("2.0.0"), req_ok(">=1.0.0 <2.0.0")),
  )
  assert_true(@moondepsolve.matches(version_ok("1.2.7"), req_ok("1.2.x")))
}

///|
test "resolve transitive dependencies with highest compatible versions" {
  let repo = registry([
    pkg("core", "1.0.0", []),
    pkg("core", "1.2.0", []),
    pkg("core", "2.0.0", []),
    pkg("http", "0.3.0", [dep("core", "^1.0.0")]),
    pkg("http", "0.3.4", [dep("core", "^1.1.0")]),
    pkg("appkit", "1.0.0", [dep("http", "~0.3.0")]),
  ])
  let result = match @moondepsolve.resolve([dep("appkit", "1.0.0")], repo) {
    Ok(result) => result
    Err(err) =>
      abort("unexpected resolve error: " + @moondepsolve.format_error(err))
  }
  assert_eq(result.packages.length(), 3)
  assert_eq(result.packages[0].name, "appkit")
  assert_eq(version_text(result.packages[0].version), "1.0.0")
  assert_eq(result.packages[1].name, "http")
  assert_eq(version_text(result.packages[1].version), "0.3.4")
  assert_eq(result.packages[2].name, "core")
  assert_eq(version_text(result.packages[2].version), "1.2.0")
}

///|
test "report conflicting transitive requirements" {
  let repo = registry([
    pkg("core", "1.5.0", []),
    pkg("core", "2.0.0", []),
    pkg("left", "1.0.0", [dep("core", "^1.0.0")]),
    pkg("right", "1.0.0", [dep("core", "^2.0.0")]),
  ])
  match
    @moondepsolve.resolve([dep("left", "1.0.0"), dep("right", "1.0.0")], repo) {
    Err(err) =>
      assert_eq(
        @moondepsolve.format_error(err),
        "conflict for core: selected 1.5.0 does not satisfy ^2.0.0 required by root -> right@1.0.0 -> core",
      )
    Ok(_) => abort("expected dependency conflict")
  }
}

///|
test "format lock output deterministically" {
  let repo = registry([
    pkg("core", "1.2.0", []),
    pkg("http", "0.3.4", [dep("core", "^1.0.0")]),
  ])
  let result = match @moondepsolve.resolve([dep("http", "~0.3.0")], repo) {
    Ok(result) => result
    Err(err) =>
      abort("unexpected resolve error: " + @moondepsolve.format_error(err))
  }
  assert_eq(
    @moondepsolve.format_lock(result),
    "# MoonDepSolve lock\nhttp 0.3.4\ncore 1.2.0\n",
  )
}
