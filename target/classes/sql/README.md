# SQL 脚本说明文档

本目录包含 ProjectAn01 项目的所有 SQL 脚本文件。

## 📁 文件列表

### 1. init_database.sql ⭐ 推荐
**用途**：完整的数据库初始化脚本（全新安装使用）

**包含内容**：
- 创建数据库 `project_an01`
- 创建所有表结构（7张表）
  - `sys_users` - 系统用户表
  - `sys_roles` - 系统角色表
  - `sys_menus` - 系统菜单表
  - `sys_user_roles` - 用户角色关联表
  - `sys_role_menus` - 角色菜单关联表
  - `categories` - 商品分类表
  - `products` - 商品表
- 初始化系统角色（3个）
- 初始化系统菜单（27个）
- 初始化商品分类（8个）
- 初始化示例商品（5个）
- 自动验证数据

**使用场景**：
- 全新安装项目
- 重建数据库
- 开发环境初始化

**执行方式**：
```bash
mysql -u root -p < init_database.sql
```

**注意事项**：
- ⚠️ 会删除旧表，请先备份数据！
- 管理员账户由应用启动时自动创建（admin / Admin@123）

---

### 2. migrate_to_sys_prefix.sql
**用途**：将现有数据库的表重命名为 sys_ 前缀（迁移使用）

**包含内容**：
- 重命名表：users → sys_users, roles → sys_roles 等
- 修复角色数据（code 和 name 字段）
- 重建外键约束
- 确保 admin 用户有正确的角色
- 自动验证结果

**使用场景**：
- 已有数据库需要迁移到新表结构
- 从旧版本升级

**执行方式**：
```bash
# 1. 先备份
mysqldump -u root -p project_an01 > backup.sql

# 2. 执行迁移
mysql -u root -p project_an01 < migrate_to_sys_prefix.sql
```

**注意事项**：
- ⚠️ 必须先备份数据库！
- 会修改表名和数据，不可逆操作
- 执行后需要重启应用

---

### 3. fix_403_permission.sql
**用途**：修复 403 Forbidden 权限问题（快速修复）

**包含内容**：
- 修复角色表的 code 和 name 字段
- 确保角色数据格式正确
- 为 admin 用户分配正确的角色
- 验证修复结果

**使用场景**：
- 登录后访问页面出现 403 错误
- 权限验证失败
- 角色数据格式错误

**执行方式**：
```bash
mysql -u root -p project_an01 < fix_403_permission.sql
```

**注意事项**：
- 适用于已有数据库的快速修复
- 不会删除数据，只修复格式
- 执行后需要重启应用

---

## 🚀 使用指南

### 场景 1：全新安装项目

```bash
# 执行完整初始化脚本
mysql -u root -p < init_database.sql

# 启动应用
# 应用会自动创建管理员账户：admin / Admin@123
```

### 场景 2：从旧版本迁移

```bash
# 1. 备份数据库
mysqldump -u root -p project_an01 > backup_$(date +%Y%m%d_%H%M%S).sql

# 2. 执行迁移脚本
mysql -u root -p project_an01 < migrate_to_sys_prefix.sql

# 3. 重启应用
```

### 场景 3：修复权限问题

```bash
# 执行权限修复脚本
mysql -u root -p project_an01 < fix_403_permission.sql

# 重启应用
```

---

## 📊 数据库结构

### 系统表（sys_ 前缀）

| 表名 | 说明 | 记录数 |
|------|------|--------|
| sys_users | 系统用户表 | 由应用创建 |
| sys_roles | 系统角色表 | 3 |
| sys_menus | 系统菜单表 | 27 |
| sys_user_roles | 用户角色关联表 | 由应用创建 |
| sys_role_menus | 角色菜单关联表 | 27 |

### 业务表

| 表名 | 说明 | 记录数 |
|------|------|--------|
| categories | 商品分类表 | 8 |
| products | 商品表 | 5 |

---

## 🔐 初始数据

### 系统角色

| ID | 名称 | 编码 | 说明 |
|----|------|------|------|
| 1 | 管理员 | ADMIN | 系统管理员，拥有所有权限 |
| 2 | 用户 | USER | 普通用户，基本权限 |
| 3 | 内容审核员 | MODERATOR | 内容审核员，审核权限 |

### 管理员账户

- **用户名**：admin
- **密码**：Admin@123
- **角色**：ADMIN + USER
- **创建方式**：应用启动时由 DataInitializer 自动创建

### 系统菜单结构

```
系统管理 (/system)
├── 用户管理 (/admin/users)
│   ├── 新增用户 (user:add)
│   ├── 编辑用户 (user:edit)
│   ├── 删除用户 (user:delete)
│   └── 重置密码 (user:reset)
├── 角色管理 (/admin/roles)
│   ├── 新增角色 (role:add)
│   ├── 编辑角色 (role:edit)
│   ├── 删除角色 (role:delete)
│   └── 分配权限 (role:permission)
└── 菜单管理 (/admin/menus)
    ├── 新增菜单 (menu:add)
    ├── 编辑菜单 (menu:edit)
    └── 删除菜单 (menu:delete)

商品管理 (/products)
├── 商品列表 (/admin/products)
│   ├── 新增商品 (product:add)
│   ├── 编辑商品 (product:edit)
│   ├── 删除商品 (product:delete)
│   ├── 上架商品 (product:online)
│   └── 下架商品 (product:offline)
└── 分类管理 (/admin/categories)
    ├── 新增分类 (category:add)
    ├── 编辑分类 (category:edit)
    └── 删除分类 (category:delete)
```

---

## ✅ 验证清单

### 数据库验证

```sql
-- 1. 检查表是否存在
SHOW TABLES;

-- 2. 检查角色数据
SELECT id, name, code, description FROM sys_roles WHERE deleted = 0;

-- 3. 检查菜单数据
SELECT COUNT(*) FROM sys_menus WHERE deleted = 0;

-- 4. 检查分类数据
SELECT COUNT(*) FROM categories WHERE deleted = 0;

-- 5. 检查商品数据
SELECT COUNT(*) FROM products WHERE deleted = 0;
```

### 应用验证

1. **启动应用**
   - 查看日志，确认 DataInitializer 执行成功
   - 应该看到：初始化角色、初始化管理员账户

2. **登录测试**
   - 访问：http://localhost:8080/auth/login
   - 用户名：admin
   - 密码：Admin@123
   - 预期：成功登录并跳转到 /dashboard

3. **权限测试**
   - 访问 /admin/users - 应该正常显示
   - 访问 /admin/roles - 应该正常显示
   - 访问 /admin/menus - 应该正常显示

---

## ⚠️ 注意事项

### 1. 备份数据
**执行任何 SQL 脚本前必须备份数据库！**

```bash
mysqldump -u root -p project_an01 > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 2. 字符集
所有表使用 `utf8mb4` 字符集，支持 emoji 和特殊字符。

### 3. 时间格式
所有时间字段使用 `DATE` 类型，格式：YYYY-MM-DD

### 4. 逻辑删除
所有表使用逻辑删除（deleted 字段），0=正常，1=已删除

### 5. 外键约束
系统表之间有外键约束，删除数据时会级联删除关联数据。

---

## 🐛 常见问题

### Q1: 执行脚本时报错 "Table doesn't exist"？
**A:** 确认数据库名称正确，使用 `USE project_an01;` 切换数据库。

### Q2: 执行脚本时报外键约束错误？
**A:** 脚本已包含 `SET FOREIGN_KEY_CHECKS = 0;`，如果还有问题，手动执行该语句。

### Q3: 管理员账户无法登录？
**A:** 
1. 检查应用日志，确认 DataInitializer 执行成功
2. 检查数据库中是否有 admin 用户
3. 检查 admin 用户是否有 ADMIN 角色

### Q4: 登录后显示 403 Forbidden？
**A:** 执行 `fix_403_permission.sql` 修复权限问题。

### Q5: 数据丢失怎么办？
**A:** 使用备份恢复：
```bash
mysql -u root -p project_an01 < backup_YYYYMMDD_HHMMSS.sql
```

---

## 📝 版本历史

### v1.0 (2024-03-14)
- 初始版本
- 包含完整的数据库初始化脚本
- 包含迁移和修复脚本
- 支持 sys_ 前缀表结构

---

## 📞 技术支持

如有问题，请查看：
- 项目根目录的 `SYS_PREFIX_MIGRATION_GUIDE.md`
- 项目根目录的 `403_FORBIDDEN_FIX.md`
- 项目根目录的 `LOGIN_REDIRECT_FIX.md`

---

**最后更新时间**：2024-03-14

