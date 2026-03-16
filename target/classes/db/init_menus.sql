-- =============================================
-- 初始化系统菜单数据
-- =============================================

USE an01;

-- =============================================
-- 清空旧数据（可选，谨慎使用）
-- =============================================
-- DELETE FROM sys_role_menus;
-- DELETE FROM sys_menus;

-- =============================================
-- 插入一级菜单
-- =============================================
INSERT INTO sys_menus (id, name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted)
VALUES
    (1, '系统管理', '/system', 'SettingOutlined', 1, NULL, 1, NULL, 'Layout', NOW(), NOW(), 0),
    (2, '商品管理', '/product', 'ShoppingOutlined', 1, NULL, 2, NULL, 'Layout', NOW(), NOW(), 0),
    (3, '订单管理', '/order', 'FileTextOutlined', 1, NULL, 3, NULL, 'Layout', NOW(), NOW(), 0),
    (4, '用户中心', '/profile', 'UserOutlined', 1, NULL, 4, NULL, 'Layout', NOW(), NOW(), 0);

-- =============================================
-- 插入二级菜单（系统管理）
-- =============================================
INSERT INTO sys_menus (id, name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted)
VALUES
    (101, '用户管理', '/system/users', 'TeamOutlined', 1, 1, 1, 'system:user:list', '/system/users/index', NOW(), NOW(), 0),
    (102, '角色管理', '/system/roles', 'SafetyOutlined', 1, 1, 2, 'system:role:list', '/system/roles/index', NOW(), NOW(), 0),
    (103, '菜单管理', '/system/menus', 'MenuOutlined', 1, 1, 3, 'system:menu:list', '/system/menus/index', NOW(), NOW(), 0);

-- =============================================
-- 插入二级菜单（商品管理）
-- =============================================
INSERT INTO sys_menus (id, name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted)
VALUES
    (201, '商品列表', '/product/list', 'UnorderedListOutlined', 1, 2, 1, 'product:list', '/product/list/index', NOW(), NOW(), 0),
    (202, '分类管理', '/product/category', 'AppstoreOutlined', 1, 2, 2, 'product:category:list', '/product/category/index', NOW(), NOW(), 0);

-- =============================================
-- 插入二级菜单（订单管理）
-- =============================================
INSERT INTO sys_menus (id, name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted)
VALUES
    (301, '订单列表', '/order/list', 'OrderedListOutlined', 1, 3, 1, 'order:list', '/order/list/index', NOW(), NOW(), 0);

-- =============================================
-- 插入二级菜单（用户中心）
-- =============================================
INSERT INTO sys_menus (id, name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted)
VALUES
    (401, '个人信息', '/profile/info', 'IdcardOutlined', 1, 4, 1, 'profile:info', '/profile/info/index', NOW(), NOW(), 0),
    (402, '修改密码', '/profile/password', 'LockOutlined', 1, 4, 2, 'profile:password', '/profile/password/index', NOW(), NOW(), 0);

-- =============================================
-- 插入按钮权限（用户管理）
-- =============================================
INSERT INTO sys_menus (id, name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted)
VALUES
    (10101, '新增用户', NULL, NULL, 2, 101, 1, 'system:user:add', NULL, NOW(), NOW(), 0),
    (10102, '编辑用户', NULL, NULL, 2, 101, 2, 'system:user:edit', NULL, NOW(), NOW(), 0),
    (10103, '删除用户', NULL, NULL, 2, 101, 3, 'system:user:delete', NULL, NOW(), NOW(), 0),
    (10104, '重置密码', NULL, NULL, 2, 101, 4, 'system:user:reset', NULL, NOW(), NOW(), 0);

-- =============================================
-- 插入按钮权限（角色管理）
-- =============================================
INSERT INTO sys_menus (id, name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted)
VALUES
    (10201, '新增角色', NULL, NULL, 2, 102, 1, 'system:role:add', NULL, NOW(), NOW(), 0),
    (10202, '编辑角色', NULL, NULL, 2, 102, 2, 'system:role:edit', NULL, NOW(), NOW(), 0),
    (10203, '删除角色', NULL, NULL, 2, 102, 3, 'system:role:delete', NULL, NOW(), NOW(), 0),
    (10204, '分配权限', NULL, NULL, 2, 102, 4, 'system:role:assign', NULL, NOW(), NOW(), 0);

-- =============================================
-- 插入按钮权限（菜单管理）
-- =============================================
INSERT INTO sys_menus (id, name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted)
VALUES
    (10301, '新增菜单', NULL, NULL, 2, 103, 1, 'system:menu:add', NULL, NOW(), NOW(), 0),
    (10302, '编辑菜单', NULL, NULL, 2, 103, 2, 'system:menu:edit', NULL, NOW(), NOW(), 0),
    (10303, '删除菜单', NULL, NULL, 2, 103, 3, 'system:menu:delete', NULL, NOW(), NOW(), 0);

-- =============================================
-- 插入按钮权限（商品管理）
-- =============================================
INSERT INTO sys_menus (id, name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted)
VALUES
    (20101, '新增商品', NULL, NULL, 2, 201, 1, 'product:add', NULL, NOW(), NOW(), 0),
    (20102, '编辑商品', NULL, NULL, 2, 201, 2, 'product:edit', NULL, NOW(), NOW(), 0),
    (20103, '删除商品', NULL, NULL, 2, 201, 3, 'product:delete', NULL, NOW(), NOW(), 0),
    (20104, '上架商品', NULL, NULL, 2, 201, 4, 'product:publish', NULL, NOW(), NOW(), 0),
    (20105, '下架商品', NULL, NULL, 2, 201, 5, 'product:unpublish', NULL, NOW(), NOW(), 0);

-- =============================================
-- 为 ADMIN 角色分配所有菜单权限
-- =============================================
INSERT INTO sys_role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM sys_roles r, sys_menus m
WHERE r.code = 'ADMIN' AND m.deleted = 0;

-- =============================================
-- 为 USER 角色分配基础菜单权限（商品查看、订单查看、个人中心）
-- =============================================
INSERT INTO sys_role_menus (role_id, menu_id)
SELECT r.id, m.id
FROM sys_roles r, sys_menus m
WHERE r.code = 'USER' 
  AND m.id IN (2, 201, 3, 301, 4, 401, 402)
  AND m.deleted = 0;

-- =============================================
-- 查看初始化结果
-- =============================================
SELECT '菜单总数' AS item, COUNT(*) AS count FROM sys_menus WHERE deleted = 0
UNION ALL
SELECT 'ADMIN角色菜单数', COUNT(*) FROM sys_role_menus rm 
    INNER JOIN sys_roles r ON rm.role_id = r.id WHERE r.code = 'ADMIN'
UNION ALL
SELECT 'USER角色菜单数', COUNT(*) FROM sys_role_menus rm 
    INNER JOIN sys_roles r ON rm.role_id = r.id WHERE r.code = 'USER';

-- 查看菜单树结构
SELECT 
    CONCAT(REPEAT('  ', CASE WHEN parent_id IS NULL THEN 0 ELSE 1 END), name) AS 菜单名称,
    path AS 路径,
    CASE type WHEN 1 THEN '菜单' WHEN 2 THEN '按钮' END AS 类型,
    permission AS 权限标识
FROM sys_menus
WHERE deleted = 0
ORDER BY 
    COALESCE(parent_id, id),
    sort_order;
