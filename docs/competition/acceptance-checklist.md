# MoonDepSolve 验收清单

## 功能验收

- [ ] `parse_version` 能解析稳定版本和 prerelease 版本。
- [ ] `compare_version` 能正确比较 major、minor、patch 和 prerelease。
- [ ] `parse_req` 能解析 exact、caret、tilde、comparator set、wildcard。
- [ ] `matches` 能判断版本是否满足约束。
- [ ] `resolve` 能完成根依赖和传递依赖求解。
- [ ] `resolve` 默认选择最高兼容版本。
- [ ] 冲突场景能返回包含依赖路径的错误说明。
- [ ] `format_lock` 输出稳定，便于测试和后续锁文件扩展。
- [ ] `moon run cmd/main` 能展示可运行示例。

## 工程验收

- [ ] `moon info && moon fmt` 执行成功。
- [ ] `moon test` 全部通过。
- [ ] `README.md` 是普通文件，非 symlink。
- [ ] 申报书 PDF 内包含有效 GitLink 和 GitHub 仓库链接。
- [ ] 仓库保留原有提交历史，满足比赛提交次数要求。

## 初审风险检查

- [ ] 项目方向已从窄范围文本处理改为成熟基础软件方向。
- [ ] 项目名称、README、申报书和 CLI 均使用 MoonDepSolve。
- [ ] 仓库内容不再保留旧项目正文叙述。
- [ ] 若后续能创建新仓库，应优先迁移到 `moondepsolve` 仓库 URL。
