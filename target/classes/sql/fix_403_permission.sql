-- ============================================
-- 快速修复脚本 - 403 权限问题
-- ============================================
-- 直接执行此脚本即可修复权限问题

-- 1. 修复角色表数据
UPDATE roles SET code = 'ADMIN', name = '管理员' WHERE name IN ('ROLE_ADMIN', '管理员') AND deleted = 0;
UPDATE roles SET code = 'USER', name = '用户' WHERE name IN ('ROLE_USER', '用户') AND deleted = 0;

-- 2. 确保角色存在
INSERT INTO roles (name, code, description, status, created_at, updated_at, deleted)
SELECT '管理员', 'ADMIN', '系统管理员', 1, CURDATE(), CURDATE(), 0
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE code = 'ADMIN' AND deleted = 0);

INSERT INTO roles (name, code, description, status, created_at, updated_at, deleted)
SELECT '用户', 'USER', '普通用户', 1, CURDATE(), CURDATE(), 0
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE code = 'USER' AND deleted = 0);

-- 3. 确保 admin 用户有正确的角色
INSERT IGNORE INTO user_roles (user_id, role_id, created_at)
SELECT u.id, r.id, CURDATE()
FROM users u, roles r
WHERE u.username = 'admin' 
  AND r.code = 'ADMIN'
  AND u.deleted = 0 
  AND r.deleted = 0;

INSERT IGNORE INTO user_roles (user_id, role_id, created_at)
SELECT u.id, r.id, CURDATE()
FROM users u, roles r
WHERE u.username = 'admin' 
  AND r.code = 'USER'
  AND u.deleted = 0 
  AND r.deleted = 0;

-- 4. 验证结果
SELECT '角色表:' AS '';
SELECT id, name, code, description FROM roles WHERE deleted = 0;

SELECT 'admin 用户角色:' AS '';
SELECT u.username, r.name, r.code
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE u.username = 'admin' AND u.deleted = 0 AND r.deleted = 0;

