# SQL 脚本索引

## 📁 文件清单

| 文件名 | 大小 | 用途 | 优先级 |
|--------|------|------|--------|
| init_database.sql | 17.8 KB | 完整数据库初始化（全新安装） | ⭐⭐⭐ |
| migrate_to_sys_prefix.sql | 6.2 KB | 迁移现有数据库到 sys_ 前缀 | ⭐⭐ |
| fix_403_permission.sql | 1.7 KB | 快速修复 403 权限问题 | ⭐⭐ |
| fix_403_permission_detailed.sql | 7.5 KB | 详细版权限修复（含故障排查） | ⭐ |
| README.md | 7.6 KB | 完整使用文档 | 📖 |

## 🎯 快速选择

### 我是新用户，第一次安装
→ 使用 `init_database.sql`

### 我已有数据库，需要升级到新版本
→ 使用 `migrate_to_sys_prefix.sql`

### 我遇到 403 Forbidden 错误
→ 使用 `fix_403_permission.sql`

### 我需要详细的故障排查
→ 使用 `fix_403_permission_detailed.sql`

## 📖 详细说明

请查看 `README.md` 获取完整文档。

