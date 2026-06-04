///|
pub(all) struct Position {
  line : Int
  column : Int
} derive(Eq)

///|
pub(all) struct LogField {
  key : String
  value : String
} derive(Eq)

///|
pub(all) struct LogEntry {
  fields : Array[LogField]
} derive(Eq)

///|
pub(all) enum QueryClause {
  FieldEquals(String, String)
  TextContains(String)
  HasField(String)
} derive(Eq)

///|
pub(all) struct Query {
  clauses : Array[QueryClause]
} derive(Eq)

///|
pub(all) struct CountBucket {
  value : String
  count : Int
} derive(Eq)

///|
pub(all) enum LogError {
  MissingKey(Position)
  MissingEquals(Position, String)
  MissingValue(Position, String)
  UnterminatedQuote(Position)
  MissingQueryValue(Position, String)
} derive(Eq)

///|
pub fn parse_line(input : String) -> Result[LogEntry, LogError] {
  parse_line_at(input, 1)
}

///|
pub fn parse_lines(input : String) -> Result[Array[LogEntry], LogError] {
  let entries : Array[LogEntry] = []
  let line = StringBuilder()
  let mut line_number = 1
  let mut previous_was_cr = false
  for c in input.iter() {
    if c == '\n' {
      let text = line.to_string()
      if text.length() > 0 {
        match parse_line_at(text, line_number) {
          Ok(entry) => entries.push(entry)
          Err(err) => return Err(err)
        }
      }
      line.reset()
      line_number += 1
      previous_was_cr = false
    } else if c == '\r' {
      let text = line.to_string()
      if text.length() > 0 {
        match parse_line_at(text, line_number) {
          Ok(entry) => entries.push(entry)
          Err(err) => return Err(err)
        }
      }
      line.reset()
      line_number += 1
      previous_was_cr = true
    } else {
      if previous_was_cr {
        previous_was_cr = false
      }
      line.write_char(c)
    }
  }
  let text = line.to_string()
  if text.length() > 0 {
    match parse_line_at(text, line_number) {
      Ok(entry) => entries.push(entry)
      Err(err) => return Err(err)
    }
  }
  Ok(entries)
}

///|
pub fn get(entry : LogEntry, key : String) -> String? {
  for field in entry.fields {
    if field.key == key {
      return Some(field.value)
    }
  }
  None
}

///|
pub fn message(entry : LogEntry) -> String {
  match get(entry, "msg") {
    Some(value) => value
    None => ""
  }
}

///|
pub fn parse_query(input : String) -> Result[Query, LogError] {
  let chars = input.iter().to_array()
  let clauses : Array[QueryClause] = []
  let mut i = 0
  while i < chars.length() {
    while i < chars.length() && is_space(chars[i]) {
      i += 1
    }
    if i >= chars.length() {
      continue
    }
    let key_start = i
    let key = StringBuilder()
    while i < chars.length() && chars[i] != ':' && !is_space(chars[i]) {
      key.write_char(chars[i])
      i += 1
    }
    let name = key.to_string()
    if name.length() == 0 {
      return Err(MissingKey({ line: 1, column: key_start + 1 }))
    }
    if i >= chars.length() || chars[i] != ':' {
      return Err(MissingEquals({ line: 1, column: i + 1 }, name))
    }
    i += 1
    if i >= chars.length() || is_space(chars[i]) {
      return Err(MissingQueryValue({ line: 1, column: i + 1 }, name))
    }
    let value_start = i
    let value = StringBuilder()
    if chars[i] == '"' {
      let quote_pos = { line: 1, column: i + 1 }
      i += 1
      let mut closed = false
      while i < chars.length() && !closed {
        if chars[i] == '\\' {
          if i + 1 < chars.length() {
            value.write_char(chars[i + 1])
            i += 2
          } else {
            value.write_char(chars[i])
            i += 1
          }
        } else if chars[i] == '"' {
          closed = true
          i += 1
        } else {
          value.write_char(chars[i])
          i += 1
        }
      }
      if !closed {
        return Err(UnterminatedQuote(quote_pos))
      }
    } else {
      while i < chars.length() && !is_space(chars[i]) {
        value.write_char(chars[i])
        i += 1
      }
    }
    let term = value.to_string()
    if term.length() == 0 {
      return Err(MissingQueryValue({ line: 1, column: value_start + 1 }, name))
    }
    if name == "text" {
      clauses.push(TextContains(term))
    } else if name == "has" {
      clauses.push(HasField(term))
    } else {
      clauses.push(FieldEquals(name, term))
    }
  }
  Ok({ clauses, })
}

///|
pub fn matches(entry : LogEntry, query : Query) -> Bool {
  for clause in query.clauses {
    match clause {
      FieldEquals(key, value) =>
        if get(entry, key) != Some(value) {
          return false
        }
      TextContains(term) => if !entry_contains(entry, term) { return false }
      HasField(key) => if get(entry, key) is None { return false }
    }
  }
  true
}

///|
pub fn filter(entries : Array[LogEntry], query : Query) -> Array[LogEntry] {
  let result : Array[LogEntry] = []
  for entry in entries {
    if matches(entry, query) {
      result.push(entry)
    }
  }
  result
}

///|
pub fn count_by(entries : Array[LogEntry], key : String) -> Array[CountBucket] {
  let buckets : Array[CountBucket] = []
  for entry in entries {
    match get(entry, key) {
      Some(value) => {
        let mut found = -1
        for i in 0..<buckets.length() {
          if found == -1 && buckets[i].value == value {
            found = i
          }
        }
        if found == -1 {
          buckets.push({ value, count: 1 })
        } else {
          let old = buckets[found]
          buckets.set(found, { value: old.value, count: old.count + 1 })
        }
      }
      None => ()
    }
  }
  buckets
}

///|
pub fn format_error(err : LogError) -> String {
  match err {
    MissingKey(pos) => "line \{pos.line}, column \{pos.column}: missing key"
    MissingEquals(pos, key) =>
      "line \{pos.line}, column \{pos.column}: missing '=' after key \{key}"
    MissingValue(pos, key) =>
      "line \{pos.line}, column \{pos.column}: missing value for key \{key}"
    UnterminatedQuote(pos) =>
      "line \{pos.line}, column \{pos.column}: unterminated quoted value"
    MissingQueryValue(pos, key) =>
      "line \{pos.line}, column \{pos.column}: missing query value for \{key}"
  }
}

///|
fn parse_line_at(
  input : String,
  line_number : Int,
) -> Result[LogEntry, LogError] {
  let chars = input.iter().to_array()
  let fields : Array[LogField] = []
  let mut i = 0
  while i < chars.length() {
    while i < chars.length() && is_space(chars[i]) {
      i += 1
    }
    if i >= chars.length() {
      continue
    }
    if chars[i] == '=' {
      return Err(MissingKey({ line: line_number, column: i + 1 }))
    }
    let key_start = i
    let key = StringBuilder()
    while i < chars.length() && chars[i] != '=' && !is_space(chars[i]) {
      key.write_char(chars[i])
      i += 1
    }
    let name = key.to_string()
    if name.length() == 0 {
      return Err(MissingKey({ line: line_number, column: key_start + 1 }))
    }
    if i >= chars.length() || chars[i] != '=' {
      return Err(MissingEquals({ line: line_number, column: i + 1 }, name))
    }
    i += 1
    if i >= chars.length() || is_space(chars[i]) {
      return Err(MissingValue({ line: line_number, column: i + 1 }, name))
    }
    let value = StringBuilder()
    if chars[i] == '"' {
      let quote_pos = { line: line_number, column: i + 1 }
      i += 1
      let mut closed = false
      while i < chars.length() && !closed {
        if chars[i] == '\\' {
          if i + 1 < chars.length() {
            value.write_char(chars[i + 1])
            i += 2
          } else {
            value.write_char(chars[i])
            i += 1
          }
        } else if chars[i] == '"' {
          closed = true
          i += 1
        } else {
          value.write_char(chars[i])
          i += 1
        }
      }
      if !closed {
        return Err(UnterminatedQuote(quote_pos))
      }
    } else {
      while i < chars.length() && !is_space(chars[i]) {
        value.write_char(chars[i])
        i += 1
      }
    }
    fields.push({ key: name, value: value.to_string() })
  }
  Ok({ fields, })
}

///|
fn entry_contains(entry : LogEntry, term : String) -> Bool {
  for field in entry.fields {
    if field.value.contains(term) {
      return true
    }
  }
  false
}

///|
fn is_space(c : Char) -> Bool {
  c == ' ' || c == '\t'
}
