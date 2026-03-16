# 数据库脚本说明

## 文件清单

| 文件 | 说明 |
|------|------|
| `schema.sql` | 建表 DDL（5张表） |
| `data.sql`   | 初始化数据（角色、用户、分类、示例商品） |

## 表结构概览

```
categories   商品分类（支持无限级父子关系）
roles        角色（ROLE_USER / ROLE_ADMIN / ROLE_MODERATOR）
users        用户
user_roles   用户角色关联（多对多）
products     商品
```

## 使用方式

### 方式一：MySQL 手动执行

```bash
mysql -u root -p < schema.sql
mysql -u root -p < data.sql
```

### 方式二：Spring Boot 自动执行（MySQL 环境）

在 `application.yml` 或 `application-prod.yml` 中添加：

```yaml
spring:
  sql:
    init:
      mode: always
      schema-locations: classpath:db/schema.sql
      data-locations:   classpath:db/data.sql
  jpa:
    hibernate:
      ddl-auto: validate   # 生产环境禁止自动改表
```

### 方式三：Docker Compose 挂载（自动初始化）

在 `docker-compose.yml` mysql 服务下挂载：

```yaml
volumes:
  - ./src/main/resources/db/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
  - ./src/main/resources/db/data.sql:/docker-entrypoint-initdb.d/02-data.sql
```

## 默认账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin    | Admin@123 | ROLE_ADMIN + ROLE_USER |
| testuser | User@123  | ROLE_USER |

> 密码已使用 BCrypt (strength=10) 加密存储。

