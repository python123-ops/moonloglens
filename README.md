# px830/mooncsv

MoonCSV 是一个面向 MoonBit 生态的 CSV/表格文本处理库，提供解析、生成、表头查询、矩形校验、错误诊断和命令行演示。

它是为 MoonBit 国产基础软件生态开源大赛准备的参赛项目。项目选题贴合官方推荐的“格式处理工具 / 可发布生态库 / 工程示例”方向，目标是做一个小而完整、可测试、可复现、可继续维护的基础库。

## 功能

- 解析普通 CSV、双引号字段、双引号转义、CRLF/LF 换行、尾随空字段。
- 生成规范 CSV，字段包含逗号、引号或换行时自动引用并转义。
- 返回带行列位置的解析错误。
- 校验每行列数是否一致。
- 按表头查询数据行单元格。
- 提供 `moon run cmd/main` 可运行演示。

## 快速开始

```bash
moon test
moon run cmd/main
```

示例输出：

```text
MoonCSV demo
rows=3, columns=3, headers=name|score|note
first note=hello, MoonBit
shape=rectangular
--- normalized csv ---
name,score,note
Ada,98,"hello, MoonBit"
Bob,87,"line1
line2"
```

## API 示例

```mbt nocheck
///|
test "read score" {
  let doc = match @mooncsv.parse("name,score\nAda,98") {
    Ok(doc) => doc
    Err(err) => fail(@mooncsv.format_error(err))
  }
  guard @mooncsv.get_by_header(doc, 0, "score") is Ok(score) else {
    fail("expected score")
  }
  assert_eq(score, "98")
}
```

公共 API：

- `parse(input : String) -> Result[Document, CsvError]`
- `parse_with(input : String, dialect : Dialect) -> Result[Document, CsvError]`
- `stringify(doc : Document) -> String`
- `headers(doc : Document) -> Array[String]`
- `validate_rectangular(doc : Document) -> Result[Unit, CsvError]`
- `get_by_header(doc : Document, row_index : Int, name : String) -> Result[String, CsvError]`
- `summarize(doc : Document) -> String`
- `format_error(err : CsvError) -> String`

## 设计说明

核心解析器是一个小型状态机，逐字符维护：

- 当前字段 `StringBuilder`
- 当前行 `Array[String]`
- 全部行 `Array[Array[String]]`
- `line` / `column` 诊断位置
- 是否处于 quoted field
- quoted field 刚结束后的合法后继字符

首版刻意不做文件 IO、流式解析、自动方言识别或类型推断。这样项目可以先把纯库 API、测试、文档和可运行示例做扎实，后续再扩展到 CLI 文件输入和大文件场景。

## 参赛材料

- 项目设计：`docs/superpowers/specs/2026-06-03-mooncsv-design.md`
- 实现计划：`docs/superpowers/plans/2026-06-03-mooncsv.md`
- 一页申报书：`docs/competition/proposal.md`
- 验收清单：`docs/competition/acceptance-checklist.md`

## 开发命令

```bash
moon info
moon fmt
moon test
moon run cmd/main
```

CI 使用同样的命令做构建与测试验证。

## License

Apache-2.0
