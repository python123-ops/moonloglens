///|
fn main {
  let sample = "ts=2026-06-04T10:00:00Z level=INFO service=api msg=started\n" +
    "ts=2026-06-04T10:00:03Z level=ERROR service=api msg=\"request timeout\" trace_id=abc123\n" +
    "ts=2026-06-04T10:00:05Z level=ERROR service=worker msg=retry"
  match @loglens.parse_lines(sample) {
    Ok(entries) => {
      println("MoonLogLens demo")
      println("entries=\{entries.length()}")
      match @loglens.parse_query("level:ERROR service:api") {
        Ok(query) => {
          let found = @loglens.filter(entries, query)
          println("query=level:ERROR service:api")
          println("matches=\{found.length()}")
          if found.length() > 0 {
            println("first_msg=" + @loglens.message(found[0]))
          }
        }
        Err(err) => println("query error: " + @loglens.format_error(err))
      }
      println("--- count_by(service) ---")
      for bucket in @loglens.count_by(entries, "service") {
        println(bucket.value + "=" + bucket.count.to_string())
      }
    }
    Err(err) => println("parse error: " + @loglens.format_error(err))
  }
}
