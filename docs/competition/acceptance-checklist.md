# MoonLogLens 验收清单

## 仓库要求

- [x] GitLink 仓库已创建。
- [x] 申报材料包含 GitHub 仓库链接。
- [x] 仓库包含 10 次以上有效提交。
- [x] 仓库包含 README、许可证、源码、测试和文档。
- [x] 项目名称、简介和申报材料一致。
- [x] README.md 使用普通文件模式，避免 symlink 克隆风险。

## 功能要求

- [x] 支持 logfmt 风格日志解析。
- [x] 支持引用值、空格和转义字符。
- [x] 支持多行日志解析和错误行列定位。
- [x] 支持字段等值查询。
- [x] 支持全文包含查询。
- [x] 支持字段存在性查询。
- [x] 支持按字段计数聚合。
- [x] 提供错误格式化。

## 可运行性

- [x] `moon test` 通过。
- [x] `moon run cmd/main` 可以运行演示。
- [x] CI 使用 `moon info`、`moon fmt --check` 和 `moon test`。

## 文档要求

- [x] README 说明项目背景、功能、API 和运行方式。
- [x] `docs/competition/proposal.md` 包含项目简介、场景、核心功能、原创性说明和技术路线。
- [x] `docs/competition/submission-guide.md` 说明报名表第 5、6、7 项如何填写，并补充 GitHub 链接要求。
- [x] `docs/competition/acceptance-checklist.md` 记录验收项。

## 后续可扩展方向

- [ ] CLI 支持读取真实日志文件。
- [ ] 增加 OR、NOT 等查询组合。
- [ ] 增加流式采集接口。
- [ ] 发布到 mooncakes.io。
