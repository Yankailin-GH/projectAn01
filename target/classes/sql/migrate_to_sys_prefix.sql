-- =============================================
-- 快速修复脚本 - 重命名表为 sys_ 前缀并修复权限
-- =============================================
-- 执行前请备份数据库！
-- 适用于已有数据的数据库迁移

-- =============================================
-- 第一步：删除外键约束
-- =============================================
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 第二步：重命名表
-- =============================================
RENAME TABLE users TO sys_users;
RENAME TABLE roles TO sys_roles;
RENAME TABLE menus TO sys_menus;
RENAME TABLE user_roles TO sys_user_roles;
RENAME TABLE role_menus TO sys_role_menus;

-- =============================================
-- 第三步：修复角色数据（确保 code 和 name 正确）
-- =============================================
UPDATE sys_roles SET 
    code = 'ADMIN', 
    name = '管理员',
    description = '系统管理员',
    status = 1,
    updated_at = CURDATE()
WHERE name IN ('ROLE_ADMIN', '管理员', 'ADMIN') 
   OR code IN ('ROLE_ADMIN', 'ADMIN')
   AND deleted = 0;

UPDATE sys_roles SET 
    code = 'USER',
    name = '用户',
    description = '普通用户',
    status = 1,
    updated_at = CURDATE()
WHERE name IN ('ROLE_USER', '用户', 'USER')
   OR code IN ('ROLE_USER', 'USER')
   AND deleted = 0;

UPDATE sys_roles SET 
    code = 'MODERATOR',
    name = '内容审核员',
    description = '内容审核员',
    status = 1,
    updated_at = CURDATE()
WHERE name IN ('ROLE_MODERATOR', '内容审核员', 'MODERATOR')
   OR code IN ('ROLE_MODERATOR', 'MODERATOR')
   AND deleted = 0;

-- =============================================
-- 第四步：确保角色存在
-- =============================================
INSERT INTO sys_roles (name, code, description, status, created_at, updated_at, deleted)
SELECT '管理员', 'ADMIN', '系统管理员', 1, CURDATE(), CURDATE(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE code = 'ADMIN' AND deleted = 0);

INSERT INTO sys_roles (name, code, description, status, created_at, updated_at, deleted)
SELECT '用户', 'USER', '普通用户', 1, CURDATE(), CURDATE(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE code = 'USER' AND deleted = 0);

INSERT INTO sys_roles (name, code, description, status, created_at, updated_at, deleted)
SELECT '内容审核员', 'MODERATOR', '内容审核员', 1, CURDATE(), CURDATE(), 0
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE code = 'MODERATOR' AND deleted = 0);

-- =============================================
-- 第五步：确保 admin 用户有正确的角色
-- =============================================
INSERT IGNORE INTO sys_user_roles (user_id, role_id, created_at)
SELECT u.id, r.id, CURDATE()
FROM sys_users u, sys_roles r
WHERE u.username = 'admin' 
  AND r.code = 'ADMIN'
  AND u.deleted = 0 
  AND r.deleted = 0;

INSERT IGNORE INTO sys_user_roles (user_id, role_id, created_at)
SELECT u.id, r.id, CURDATE()
FROM sys_users u, sys_roles r
WHERE u.username = 'admin' 
  AND r.code = 'USER'
  AND u.deleted = 0 
  AND r.deleted = 0;

-- =============================================
-- 第六步：重新添加外键约束
-- =============================================
ALTER TABLE sys_user_roles 
    DROP FOREIGN KEY IF EXISTS user_roles_ibfk_1,
    DROP FOREIGN KEY IF EXISTS user_roles_ibfk_2,
    DROP FOREIGN KEY IF EXISTS fk_ur_user,
    DROP FOREIGN KEY IF EXISTS fk_ur_role;

ALTER TABLE sys_user_roles 
    ADD CONSTRAINT fk_sys_user_roles_user FOREIGN KEY (user_id) REFERENCES sys_users(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_sys_user_roles_role FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE;

ALTER TABLE sys_role_menus 
    DROP FOREIGN KEY IF EXISTS role_menus_ibfk_1,
    DROP FOREIGN KEY IF EXISTS role_menus_ibfk_2;

ALTER TABLE sys_role_menus 
    ADD CONSTRAINT fk_sys_role_menus_role FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_sys_role_menus_menu FOREIGN KEY (menu_id) REFERENCES sys_menus(id) ON DELETE CASCADE;

-- =============================================
-- 第七步：更新表注释
-- =============================================
ALTER TABLE sys_users COMMENT='系统用户表';
ALTER TABLE sys_roles COMMENT='系统角色表';
ALTER TABLE sys_menus COMMENT='系统菜单表';
ALTER TABLE sys_user_roles COMMENT='系统用户角色关联表';
ALTER TABLE sys_role_menus COMMENT='系统角色菜单关联表';

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- 验证结果
-- =============================================
SELECT '=== 系统角色表 ===' AS '';
SELECT id, name, code, description, status FROM sys_roles WHERE deleted = 0;

SELECT '=== admin 用户角色 ===' AS '';
SELECT 
    u.id AS user_id,
    u.username,
    u.full_name,
    r.name AS role_name,
    r.code AS role_code
FROM sys_users u
INNER JOIN sys_user_roles ur ON u.id = ur.user_id
INNER JOIN sys_roles r ON ur.role_id = r.id
WHERE u.username = 'admin' AND u.deleted = 0 AND r.deleted = 0;

SELECT '=== 所有表列表 ===' AS '';
SHOW TABLES LIKE 'sys_%';

-- =============================================
-- 预期结果
-- =============================================
-- 系统角色表应该显示：
-- +----+----------+----------+--------------+------+
-- | id | name     | code     | description  | status |
-- +----+----------+----------+--------------+------+
-- |  1 | 管理员    | ADMIN    | 系统管理员    |    1 |
-- |  2 | 用户      | USER     | 普通用户      |    1 |
-- +----+----------+----------+--------------+------+

-- admin 用户角色应该显示：
-- +---------+----------+--------+-----------+-----------+
-- | user_id | username | full_name | role_name | role_code |
-- +---------+----------+--------+-----------+-----------+
-- |       1 | admin    | 系统... | 管理员     | ADMIN     |
-- |       1 | admin    | 系统... | 用户       | USER      |
-- +---------+----------+--------+-----------+-----------+

-- 表列表应该显示：
-- sys_users
-- sys_roles
-- sys_menus
-- sys_user_roles
-- sys_role_menus

