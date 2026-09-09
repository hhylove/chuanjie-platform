# V2 重建回滚说明

## 1. 恢复基线

R0使用本地 Git 提交保存删除前状态，不创建远程仓库。提交完成后记录提交哈希。恢复操作必须精确到删除批次或文件，禁止使用 `git reset --hard` 覆盖用户的后续修改。

推荐恢复方式：

```powershell
# 查看基线中的文件，不修改工作区
git -c safe.directory=D:/code/chuanjie show <baseline-commit>:<path>

# 经确认后，仅恢复明确文件
git -c safe.directory=D:/code/chuanjie restore --source <baseline-commit> -- <path>
```

## 2. 可再生成内容恢复

```powershell
mvn -f cj-platform-server/pom.xml test
pnpm --dir cj-platform-web install --frozen-lockfile
pnpm --dir cj-platform-web typecheck
pnpm --dir cj-platform-web build
```

如果依赖下载失败，应保留现有依赖目录，待网络或镜像源恢复后再执行清理。

## 3. 数据库回滚

- V2 使用新数据库或新 schema 建立迁移，不在原 V1 数据库上覆盖重建。
- 迁移前生成逻辑备份、全局对象清单和 SHA-256 校验记录。
- 切换失败时停止 V2 写入，恢复 V1 数据库路由；不得通过删除迁移表强行回退。
- 数据库恢复演练通过前，不删除任何 V1 数据或备份。

## 4. 分批原则

- 每批只处理一种类型或一个模块。
- 删除前记录 `git status`，删除后立即运行对应测试。
- 验证失败时停止下一批，仅恢复本批涉及文件。
- 恢复完成后再次运行同一验证命令，并在进度日志记录原因。
