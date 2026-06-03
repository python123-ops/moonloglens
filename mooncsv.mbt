///|
pub(all) struct Position {
  line : Int
  column : Int
} derive(Eq)

///|
pub(all) struct Dialect {
  delimiter : Char
  quote : Char
} derive(Eq)

///|
pub(all) struct Document {
  rows : Array[Array[String]]
} derive(Eq)

///|
pub(all) enum CsvError {
  UnterminatedQuote(Position)
  BareQuote(Position)
  UnexpectedCharacter(Position, Char)
  InconsistentColumns(Int, Int, Int)
  MissingHeader(String)
  RowOutOfRange(Int)
} derive(Eq)

///|
pub fn default_dialect() -> Dialect {
  { delimiter: ',', quote: '"' }
}

///|
pub fn parse(input : String) -> Result[Document, CsvError] {
  parse_with(input, default_dialect())
}

///|
pub fn parse_with(
  input : String,
  dialect : Dialect,
) -> Result[Document, CsvError] {
  let chars = input.iter().to_array()
  let rows : Array[Array[String]] = []
  let mut row : Array[String] = []
  let field = StringBuilder()
  let mut i = 0
  let mut line = 1
  let mut column = 1
  let mut in_quotes = false
  let mut just_closed_quote = false
  let mut quote_start = { line, column }
  let push_field = fn() {
    row.push(field.to_string())
    field.reset()
  }
  let push_row = fn() {
    push_field()
    rows.push(row)
    row = []
  }
  while i < chars.length() {
    let c = chars[i]
    if in_quotes {
      if c == dialect.quote {
        if i + 1 < chars.length() && chars[i + 1] == dialect.quote {
          field.write_char(dialect.quote)
          i += 2
          column += 2
        } else {
          in_quotes = false
          just_closed_quote = true
          i += 1
          column += 1
        }
      } else if c == '\r' {
        if i + 1 < chars.length() && chars[i + 1] == '\n' {
          field.write_char('\n')
          i += 2
        } else {
          field.write_char('\n')
          i += 1
        }
        line += 1
        column = 1
      } else {
        field.write_char(c)
        i += 1
        if c == '\n' {
          line += 1
          column = 1
        } else {
          column += 1
        }
      }
    } else if just_closed_quote {
      if c == dialect.delimiter {
        push_field()
        just_closed_quote = false
        i += 1
        column += 1
      } else if c == '\n' {
        push_row()
        just_closed_quote = false
        i += 1
        line += 1
        column = 1
      } else if c == '\r' {
        push_row()
        just_closed_quote = false
        if i + 1 < chars.length() && chars[i + 1] == '\n' {
          i += 2
        } else {
          i += 1
        }
        line += 1
        column = 1
      } else {
        return Err(UnexpectedCharacter({ line, column }, c))
      }
    } else if c == dialect.quote {
      if field.to_string().length() == 0 {
        in_quotes = true
        quote_start = { line, column }
        i += 1
        column += 1
      } else {
        return Err(BareQuote({ line, column }))
      }
    } else if c == dialect.delimiter {
      push_field()
      i += 1
      column += 1
    } else if c == '\n' {
      push_row()
      i += 1
      line += 1
      column = 1
    } else if c == '\r' {
      push_row()
      if i + 1 < chars.length() && chars[i + 1] == '\n' {
        i += 2
      } else {
        i += 1
      }
      line += 1
      column = 1
    } else {
      field.write_char(c)
      i += 1
      column += 1
    }
  }
  if in_quotes {
    return Err(UnterminatedQuote(quote_start))
  }
  if row.length() > 0 || field.to_string().length() > 0 || just_closed_quote {
    push_field()
    rows.push(row)
  }
  Ok({ rows, })
}

///|
pub fn stringify(doc : Document) -> String {
  let out = StringBuilder()
  for row_index in 0..<doc.rows.length() {
    if row_index > 0 {
      out.write_char('\n')
    }
    let row = doc.rows[row_index]
    for column_index in 0..<row.length() {
      if column_index > 0 {
        out.write_char(',')
      }
      out.write_string(escape_field(row[column_index]))
    }
  }
  out.to_string()
}

///|
pub fn headers(doc : Document) -> Array[String] {
  if doc.rows.length() == 0 {
    []
  } else {
    doc.rows[0]
  }
}

///|
pub fn validate_rectangular(doc : Document) -> Result[Unit, CsvError] {
  if doc.rows.length() == 0 {
    return Ok(())
  }
  let expected = doc.rows[0].length()
  for row_index in 1..<doc.rows.length() {
    let actual = doc.rows[row_index].length()
    if actual != expected {
      return Err(InconsistentColumns(row_index + 1, expected, actual))
    }
  }
  Ok(())
}

///|
pub fn get_by_header(
  doc : Document,
  row_index : Int,
  name : String,
) -> Result[String, CsvError] {
  let names = headers(doc)
  let mut column_index = -1
  for i in 0..<names.length() {
    if column_index == -1 && names[i] == name {
      column_index = i
    }
  }
  if column_index == -1 {
    return Err(MissingHeader(name))
  }
  let physical_row = row_index + 1
  if physical_row < 1 || physical_row >= doc.rows.length() {
    return Err(RowOutOfRange(row_index))
  }
  let row = doc.rows[physical_row]
  if column_index >= row.length() {
    return Err(
      InconsistentColumns(physical_row + 1, names.length(), row.length()),
    )
  }
  Ok(row[column_index])
}

///|
pub fn summarize(doc : Document) -> String {
  let columns = if doc.rows.length() == 0 { 0 } else { doc.rows[0].length() }
  "rows=\{doc.rows.length()}, columns=\{columns}, headers=\{headers(doc).join("|")}"
}

///|
pub fn format_error(err : CsvError) -> String {
  match err {
    UnterminatedQuote(pos) =>
      "line \{pos.line}, column \{pos.column}: unterminated quoted field"
    BareQuote(pos) => "line \{pos.line}, column \{pos.column}: bare quote"
    UnexpectedCharacter(pos, c) =>
      "line \{pos.line}, column \{pos.column}: unexpected character after quote: \{c}"
    InconsistentColumns(row, expected, actual) =>
      "row \{row} has \{actual} columns, expected \{expected}"
    MissingHeader(name) => "missing header: \{name}"
    RowOutOfRange(row) => "row out of range: \{row}"
  }
}

///|
fn escape_field(value : String) -> String {
  if !needs_quotes(value) {
    return value
  }
  let out = StringBuilder()
  out.write_char('"')
  for c in value.iter() {
    if c == '"' {
      out.write_string("\"\"")
    } else {
      out.write_char(c)
    }
  }
  out.write_char('"')
  out.to_string()
}

///|
fn needs_quotes(value : String) -> Bool {
  for c in value.iter() {
    if c == ',' || c == '"' || c == '\n' || c == '\r' {
      return true
    }
  }
  false
}
