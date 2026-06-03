# MoonCSV Design

## 比赛理解

MoonBit 国产基础软件生态开源大赛鼓励参赛者做一个可发布的 MoonBit 生态项目。官方页面强调项目可以是原创库、成熟生态库的 MoonBit 移植、开发者工具或示例项目；验收时需要公开仓库、清晰 README、可运行示例、CI、测试，并为 mooncakes.io 发布做好准备。推荐方向覆盖数据结构与算法、工程基础设施、运行时与格式处理、应用生态。

## 项目定位

MoonCSV 是一个 MoonBit CSV/表格文本解析与生成库，目标是提供可复用、可测试、可维护的基础格式处理能力。它面向需要把日志、课程数据、配置表、标注数据或小型数据集导入 MoonBit 程序的开发者。

项目选择 CSV 而不是更大的数据库或编译器工具，是为了在比赛周期内做出完整闭环：核心解析器、错误诊断、序列化、表格校验、命令行示例、测试、文档和申报材料都能落地。

## 核心功能

1. 解析 CSV 文本为 `Document`，支持逗号分隔、双引号字段、双引号转义、CRLF/LF 换行、尾随空字段和空行。
2. 生成 CSV 文本，按 RFC 4180 常见规则自动引用包含逗号、引号或换行的字段。
3. 提供带行列位置的错误：未闭合引号、裸引号、引号后非法字符。
4. 提供表格辅助：读取表头、检测每行列数是否一致、按表头查询单元格。
5. 提供一个可运行 CLI 示例：`moon run cmd/main` 打印内置样例的解析摘要和重新生成的 CSV。

## 非目标

首版不做文件 IO、流式解析、类型推断、数据库导入、方言自动识别或大型数据性能优化。文件 IO 和更多方言选项适合作为比赛后续迭代。

## API 设计

公共类型：

- `Position`：错误位置，包含 `line` 和 `column`。
- `CsvError`：解析和校验错误。
- `Document`：二维表格，保存 `rows : Array[Array[String]]`。
- `Dialect`：CSV 方言，首版公开默认配置。

公共函数：

- `parse(input : String) -> Result[Document, CsvError]`
- `parse_with(input : String, dialect : Dialect) -> Result[Document, CsvError]`
- `stringify(doc : Document) -> String`
- `headers(doc : Document) -> Array[String]`
- `validate_rectangular(doc : Document) -> Result[Unit, CsvError]`
- `get_by_header(doc : Document, row : Int, name : String) -> Result[String, CsvError]`
- `summarize(doc : Document) -> String`

## 架构

核心库保留在根包 `px830/mooncsv`。解析器使用一个小型状态机逐字符扫描字符串，维护当前位置、当前字段、当前行和结果表。生成器使用 `StringBuilder` 拼接字段和行。表格辅助函数基于 `Document`，不依赖解析器内部状态。

CLI 位于 `cmd/main`，通过包依赖调用核心库。文档放在 `README.mbt.md` 和 `docs/competition`，CI 放在 `.github/workflows/ci.yml`。

## 测试策略

黑盒测试覆盖公开 API：普通解析、引号、换行、转义、尾随字段、生成、表头查询和列数校验。白盒测试覆盖内部字符分类和字段引用判断。每轮实现先写失败测试，再实现最小代码，通过后再扩展。

## 交付物

- 可构建 MoonBit 包。
- 可运行 CLI 示例。
- 覆盖核心行为的测试。
- README：安装、运行、API、示例、设计说明。
- 参赛申报材料：一页项目提案、开发路线和验收清单。
- Apache-2.0 许可证与 GitHub Actions CI。
