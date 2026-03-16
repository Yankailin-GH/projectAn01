-- ============================================
-- 403 Forbidden 权限问题 - 数据库修复脚本
-- ============================================
-- 说明：修复角色表中的 code 字段，确保权限验证正常工作
-- 执行前请备份数据库！

-- 1. 检查当前角色数据
SELECT id, name, code, description, status 
FROM roles 
WHERE deleted = 0;

-- 2. 修复角色编码（如果 code 字段为空或错误）
-- 将中文名称或 ROLE_ADMIN 格式转换为 ADMIN 格式

UPDATE roles 
SET code = 'ADMIN', 
    name = '管理员',
    description = '系统管理员',
    status = 1,
    updated_at = CURDATE()
WHERE (name = 'ROLE_ADMIN' OR name = '管理员' OR code = 'ROLE_ADMIN' OR code IS NULL)
  AND deleted = 0;

UPDATE roles 
SET code = 'USER',
    name = '用户',
    description = '普通用户',
    status = 1,
    updated_at = CURDATE()
WHERE (name = 'ROLE_USER' OR name = '用户' OR code = 'ROLE_USER' OR code IS NULL)
  AND deleted = 0;

UPDATE roles 
SET code = 'MODERATOR',
    name = '内容审核员',
    description = '内容审核员',
    status = 1,
    updated_at = CURDATE()
WHERE (name = 'ROLE_MODERATOR' OR name = '内容审核员' OR code = 'ROLE_MODERATOR' OR code IS NULL)
  AND deleted = 0;

-- 3. 如果角色不存在，则插入
INSERT INTO roles (name, code, description, status, created_at, updated_at, deleted)
SELECT '管理员', 'ADMIN', '系统管理员', 1, CURDATE(), CURDATE(), 0
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE code = 'ADMIN' AND deleted = 0);

INSERT INTO roles (name, code, description, status, created_at, updated_at, deleted)
SELECT '用户', 'USER', '普通用户', 1, CURDATE(), CURDATE(), 0
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE code = 'USER' AND deleted = 0);

-- 4. 验证修复结果
SELECT 
    id,
    name AS '角色名称',
    code AS '角色编码',
    description AS '描述',
    status AS '状态'
FROM roles 
WHERE deleted = 0
ORDER BY id;

-- 预期结果：
-- +----+----------+----------+--------------+------+
-- | id | 角色名称  | 角色编码  | 描述          | 状态 |
-- +----+----------+----------+--------------+------+
-- |  1 | 管理员    | ADMIN    | 系统管理员    |    1 |
-- |  2 | 用户      | USER     | 普通用户      |    1 |
-- +----+----------+----------+--------------+------+

-- 5. 验证 admin 用户的角色关联
SELECT 
    u.id AS '用户ID',
    u.username AS '用户名',
    u.full_name AS '姓名',
    r.name AS '角色名称',
    r.code AS '角色编码'
FROM users u
INNER JOIN user_roles ur ON u.id = ur.user_id
INNER JOIN roles r ON ur.role_id = r.id
WHERE u.username = 'admin' 
  AND u.deleted = 0 
  AND r.deleted = 0
ORDER BY r.id;

-- 预期结果：admin 用户应该有 ADMIN 和 USER 两个角色
-- +--------+----------+--------+----------+----------+
-- | 用户ID | 用户名    | 姓名    | 角色名称  | 角色编码  |
-- +--------+----------+--------+----------+----------+
-- |      1 | admin    | 系统... | 管理员    | ADMIN    |
-- |      1 | admin    | 系统... | 用户      | USER     |
-- +--------+----------+--------+----------+----------+

-- 6. 如果 admin 用户缺少角色关联，手动添加
-- 首先获取 admin 用户 ID 和角色 ID
SET @admin_user_id = (SELECT id FROM users WHERE username = 'admin' AND deleted = 0 LIMIT 1);
SET @admin_role_id = (SELECT id FROM roles WHERE code = 'ADMIN' AND deleted = 0 LIMIT 1);
SET @user_role_id = (SELECT id FROM roles WHERE code = 'USER' AND deleted = 0 LIMIT 1);

-- 添加 ADMIN 角色（如果不存在）
INSERT IGNORE INTO user_roles (user_id, role_id, created_at)
SELECT @admin_user_id, @admin_role_id, CURDATE()
WHERE @admin_user_id IS NOT NULL AND @admin_role_id IS NOT NULL;

-- 添加 USER 角色（如果不存在）
INSERT IGNORE INTO user_roles (user_id, role_id, created_at)
SELECT @admin_user_id, @user_role_id, CURDATE()
WHERE @admin_user_id IS NOT NULL AND @user_role_id IS NOT NULL;

-- 7. 最终验证
SELECT '=== 角色表验证 ===' AS '';
SELECT id, name, code, description, status FROM roles WHERE deleted = 0;

SELECT '=== admin 用户角色验证 ===' AS '';
SELECT 
    u.username,
    r.name AS role_name,
    r.code AS role_code
FROM users u
INNER JOIN user_roles ur ON u.id = ur.user_id
INNER JOIN roles r ON ur.role_id = r.id
WHERE u.username = 'admin' AND u.deleted = 0 AND r.deleted = 0;

-- 8. 清理重复或错误的角色数据（可选，谨慎执行）
-- 如果有多个 ADMIN 角色，只保留一个
-- DELETE FROM roles 
-- WHERE code = 'ADMIN' 
--   AND id NOT IN (SELECT MIN(id) FROM (SELECT id FROM roles WHERE code = 'ADMIN' AND deleted = 0) AS t)
--   AND deleted = 0;

-- ============================================
-- 执行完成后的检查清单
-- ============================================
-- ✅ roles 表中 code 字段正确：ADMIN, USER
-- ✅ roles 表中 name 字段为中文：管理员, 用户
-- ✅ admin 用户关联了 ADMIN 和 USER 角色
-- ✅ user_roles 表中的关联关系正确

-- ============================================
-- 故障排查 SQL
-- ============================================

-- 查看所有用户及其角色
SELECT 
    u.id,
    u.username,
    u.full_name,
    GROUP_CONCAT(r.code ORDER BY r.code) AS role_codes,
    GROUP_CONCAT(r.name ORDER BY r.code) AS role_names
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id AND r.deleted = 0
WHERE u.deleted = 0
GROUP BY u.id, u.username, u.full_name;

-- 查看孤立的角色（没有用户关联）
SELECT r.* 
FROM roles r
LEFT JOIN user_roles ur ON r.id = ur.role_id
WHERE ur.id IS NULL AND r.deleted = 0;

-- 查看孤立的用户（没有角色）
SELECT u.* 
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
WHERE ur.id IS NULL AND u.deleted = 0;

