///|
fn main {
  let sample = "name,score,note\nAda,98,\"hello, MoonBit\"\nBob,87,\"line1\nline2\""
  match @csv.parse(sample) {
    Ok(doc) => {
      println("MoonCSV demo")
      println(@csv.summarize(doc))
      match @csv.get_by_header(doc, 0, "note") {
        Ok(note) => println("first note=" + note)
        Err(err) => println("lookup error: " + @csv.format_error(err))
      }
      match @csv.validate_rectangular(doc) {
        Ok(_) => println("shape=rectangular")
        Err(err) => println("shape error: " + @csv.format_error(err))
      }
      println("--- normalized csv ---")
      println(@csv.stringify(doc))
    }
    Err(err) => println("parse error: " + @csv.format_error(err))
  }
}
