-- =============================================
-- ProjectAn01 完整数据库初始化脚本
-- 数据库: MySQL 8.0
-- 字符集: utf8mb4
-- 说明: 包含所有表结构、索引、外键和初始数据
-- =============================================

-- 删除旧数据库（谨慎使用！）
-- DROP DATABASE IF EXISTS project_an01;

-- 创建数据库
CREATE DATABASE IF NOT EXISTS project_an01
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE project_an01;

-- 禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 系统用户表
-- =============================================
DROP TABLE IF EXISTS sys_users;
CREATE TABLE sys_users (
    id                 BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    username           VARCHAR(50)  NOT NULL                COMMENT '用户名（唯一）',
    email              VARCHAR(100) NOT NULL                COMMENT '邮箱（唯一）',
    password           VARCHAR(255) NOT NULL                COMMENT '密码（BCrypt加密）',
    full_name          VARCHAR(100)                         COMMENT '真实姓名',
    phone              VARCHAR(20)                          COMMENT '手机号',
    avatar_url         VARCHAR(500)                         COMMENT '头像URL',
    enabled            TINYINT(1)   NOT NULL DEFAULT 1      COMMENT '账号是否启用',
    status             INT          NOT NULL DEFAULT 1      COMMENT '状态：0=禁用，1=启用',
    account_non_locked TINYINT(1)   NOT NULL DEFAULT 1      COMMENT '账号是否未锁定',
    -- 审计字段
    created_at         DATE         NOT NULL                COMMENT '注册时间',
    updated_at         DATE                                 COMMENT '最后修改时间',
    created_by         VARCHAR(100)                         COMMENT '创建人',
    updated_by         VARCHAR(100)                         COMMENT '最后修改人',
    deleted            INT          NOT NULL DEFAULT 0      COMMENT '逻辑删除（0=正常,1=已删除）',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email),
    KEY idx_enabled (enabled),
    KEY idx_status (status),
    KEY idx_deleted (deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统用户表';

-- =============================================
-- 系统角色表
-- =============================================
DROP TABLE IF EXISTS sys_roles;
CREATE TABLE sys_roles (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    name        VARCHAR(64)  NOT NULL                COMMENT '角色名称（中文）',
    code        VARCHAR(64)  NOT NULL                COMMENT '角色编码（ADMIN/USER/MODERATOR）',
    description VARCHAR(255)                         COMMENT '角色描述',
    status      INT          NOT NULL DEFAULT 1      COMMENT '状态：0=禁用，1=启用',
    -- 审计字段
    created_at  DATE         NOT NULL                COMMENT '创建时间',
    updated_at  DATE                                 COMMENT '最后修改时间',
    created_by  VARCHAR(100)                         COMMENT '创建人',
    updated_by  VARCHAR(100)                         COMMENT '最后修改人',
    deleted     INT          NOT NULL DEFAULT 0      COMMENT '逻辑删除',
    PRIMARY KEY (id),
    UNIQUE KEY uk_code (code),
    KEY idx_status (status),
    KEY idx_deleted (deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统角色表';

-- =============================================
-- 系统菜单表（包含菜单和按钮）
-- =============================================
DROP TABLE IF EXISTS sys_menus;
CREATE TABLE sys_menus (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    name        VARCHAR(64)  NOT NULL                COMMENT '菜单名称',
    path        VARCHAR(255)                         COMMENT '路由路径',
    icon        VARCHAR(64)                          COMMENT '图标',
    type        INT          NOT NULL DEFAULT 1      COMMENT '类型：1=菜单，2=按钮',
    parent_id   BIGINT                               COMMENT '父菜单ID',
    sort_order  INT          NOT NULL DEFAULT 0      COMMENT '排序',
    permission  VARCHAR(255)                         COMMENT '权限标识',
    component   VARCHAR(255)                         COMMENT '组件路径',
    -- 审计字段
    created_at  DATE         NOT NULL                COMMENT '创建时间',
    updated_at  DATE                                 COMMENT '最后修改时间',
    created_by  VARCHAR(100)                         COMMENT '创建人',
    updated_by  VARCHAR(100)                         COMMENT '最后修改人',
    deleted     INT          NOT NULL DEFAULT 0      COMMENT '逻辑删除',
    PRIMARY KEY (id),
    KEY idx_parent_id (parent_id),
    KEY idx_type (type),
    KEY idx_sort_order (sort_order),
    KEY idx_deleted (deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统菜单表';

-- =============================================
-- 系统用户角色关联表
-- =============================================
DROP TABLE IF EXISTS sys_user_roles;
CREATE TABLE sys_user_roles (
    id         BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    user_id    BIGINT NOT NULL                COMMENT '用户ID',
    role_id    BIGINT NOT NULL                COMMENT '角色ID',
    created_at DATE                           COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_role (user_id, role_id),
    KEY idx_user_id (user_id),
    KEY idx_role_id (role_id),
    CONSTRAINT fk_sys_user_roles_user FOREIGN KEY (user_id) REFERENCES sys_users(id) ON DELETE CASCADE,
    CONSTRAINT fk_sys_user_roles_role FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统用户角色关联表';

-- =============================================
-- 系统角色菜单关联表
-- =============================================
DROP TABLE IF EXISTS sys_role_menus;
CREATE TABLE sys_role_menus (
    id         BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    role_id    BIGINT NOT NULL                COMMENT '角色ID',
    menu_id    BIGINT NOT NULL                COMMENT '菜单ID',
    created_at DATE                           COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_role_menu (role_id, menu_id),
    KEY idx_role_id (role_id),
    KEY idx_menu_id (menu_id),
    CONSTRAINT fk_sys_role_menus_role FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    CONSTRAINT fk_sys_role_menus_menu FOREIGN KEY (menu_id) REFERENCES sys_menus(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统角色菜单关联表';

-- =============================================
-- 商品分类表
-- =============================================
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    name        VARCHAR(100) NOT NULL                COMMENT '分类名称',
    description VARCHAR(500)                         COMMENT '分类描述',
    sort_order  INT          NOT NULL DEFAULT 0      COMMENT '排序权重（越小越靠前）',
    parent_id   BIGINT                               COMMENT '父分类ID（NULL表示根分类）',
    -- 审计字段
    created_at  DATE         NOT NULL                COMMENT '创建时间',
    updated_at  DATE                                 COMMENT '最后修改时间',
    created_by  VARCHAR(100)                         COMMENT '创建人',
    updated_by  VARCHAR(100)                         COMMENT '最后修改人',
    deleted     INT          NOT NULL DEFAULT 0      COMMENT '逻辑删除（0=正常,1=已删除）',
    PRIMARY KEY (id),
    KEY idx_parent_id (parent_id),
    KEY idx_sort_order (sort_order),
    KEY idx_deleted (deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品分类表';

-- =============================================
-- 商品表
-- =============================================
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id          BIGINT         NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    name        VARCHAR(200)   NOT NULL                COMMENT '商品名称',
    description TEXT                                   COMMENT '商品描述',
    price       DECIMAL(12, 2) NOT NULL                COMMENT '售价',
    stock       INT            NOT NULL DEFAULT 0      COMMENT '库存数量',
    image_url   VARCHAR(500)                           COMMENT '商品主图URL',
    sku         VARCHAR(100)                           COMMENT '商品编码（唯一）',
    status      VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE' COMMENT '状态（ACTIVE/INACTIVE/OUT_OF_STOCK）',
    category_id BIGINT                                 COMMENT '所属分类ID',
    -- 审计字段
    created_at  DATE           NOT NULL                COMMENT '创建时间',
    updated_at  DATE                                   COMMENT '最后修改时间',
    created_by  VARCHAR(100)                           COMMENT '创建人',
    updated_by  VARCHAR(100)                           COMMENT '最后修改人',
    deleted     INT            NOT NULL DEFAULT 0      COMMENT '逻辑删除',
    PRIMARY KEY (id),
    UNIQUE KEY uk_sku (sku),
    KEY idx_status (status),
    KEY idx_category_id (category_id),
    KEY idx_price (price),
    KEY idx_deleted (deleted),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品表';

-- 启用外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- 初始化系统角色数据
-- =============================================
INSERT INTO sys_roles (name, code, description, status, created_at, updated_at, deleted) VALUES 
('管理员', 'ADMIN', '系统管理员，拥有所有权限', 1, CURDATE(), CURDATE(), 0),
('用户', 'USER', '普通用户，基本权限', 1, CURDATE(), CURDATE(), 0),
('内容审核员', 'MODERATOR', '内容审核员，审核权限', 1, CURDATE(), CURDATE(), 0);

-- =============================================
-- 初始化系统菜单数据
-- =============================================
INSERT INTO sys_menus (name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, deleted) VALUES
-- 一级菜单
('系统管理', '/system', 'setting', 1, NULL, 0, NULL, NULL, CURDATE(), CURDATE(), 0),
('商品管理', '/products', 'shopping', 1, NULL, 1, NULL, NULL, CURDATE(), CURDATE(), 0),

-- 系统管理子菜单
('用户管理', '/admin/users', 'user', 1, 1, 1, 'user:view', '/admin/users', CURDATE(), CURDATE(), 0),
('角色管理', '/admin/roles', 'team', 1, 1, 2, 'role:view', '/admin/roles', CURDATE(), CURDATE(), 0),
('菜单管理', '/admin/menus', 'menu', 1, 1, 3, 'menu:view', '/admin/menus', CURDATE(), CURDATE(), 0),

-- 商品管理子菜单
('商品列表', '/admin/products', 'list', 1, 2, 1, 'product:view', '/admin/products', CURDATE(), CURDATE(), 0),
('分类管理', '/admin/categories', 'folder', 1, 2, 2, 'category:view', '/admin/categories', CURDATE(), CURDATE(), 0),

-- 用户管理按钮
('新增用户', NULL, 'plus', 2, 3, 0, 'user:add', NULL, CURDATE(), CURDATE(), 0),
('编辑用户', NULL, 'edit', 2, 3, 1, 'user:edit', NULL, CURDATE(), CURDATE(), 0),
('删除用户', NULL, 'delete', 2, 3, 2, 'user:delete', NULL, CURDATE(), CURDATE(), 0),
('重置密码', NULL, 'key', 2, 3, 3, 'user:reset', NULL, CURDATE(), CURDATE(), 0),

-- 角色管理按钮
('新增角色', NULL, 'plus', 2, 4, 0, 'role:add', NULL, CURDATE(), CURDATE(), 0),
('编辑角色', NULL, 'edit', 2, 4, 1, 'role:edit', NULL, CURDATE(), CURDATE(), 0),
('删除角色', NULL, 'delete', 2, 4, 2, 'role:delete', NULL, CURDATE(), CURDATE(), 0),
('分配权限', NULL, 'lock', 2, 4, 3, 'role:permission', NULL, CURDATE(), CURDATE(), 0),

-- 菜单管理按钮
('新增菜单', NULL, 'plus', 2, 5, 0, 'menu:add', NULL, CURDATE(), CURDATE(), 0),
('编辑菜单', NULL, 'edit', 2, 5, 1, 'menu:edit', NULL, CURDATE(), CURDATE(), 0),
('删除菜单', NULL, 'delete', 2, 5, 2, 'menu:delete', NULL, CURDATE(), CURDATE(), 0),

-- 商品管理按钮
('新增商品', NULL, 'plus', 2, 6, 0, 'product:add', NULL, CURDATE(), CURDATE(), 0),
('编辑商品', NULL, 'edit', 2, 6, 1, 'product:edit', NULL, CURDATE(), CURDATE(), 0),
('删除商品', NULL, 'delete', 2, 6, 2, 'product:delete', NULL, CURDATE(), CURDATE(), 0),
('上架商品', NULL, 'check', 2, 6, 3, 'product:online', NULL, CURDATE(), CURDATE(), 0),
('下架商品', NULL, 'close', 2, 6, 4, 'product:offline', NULL, CURDATE(), CURDATE(), 0),

-- 分类管理按钮
('新增分类', NULL, 'plus', 2, 7, 0, 'category:add', NULL, CURDATE(), CURDATE(), 0),
('编辑分类', NULL, 'edit', 2, 7, 1, 'category:edit', NULL, CURDATE(), CURDATE(), 0),
('删除分类', NULL, 'delete', 2, 7, 2, 'category:delete', NULL, CURDATE(), CURDATE(), 0);

-- =============================================
-- 管理员角色分配所有菜单权限
-- =============================================
INSERT INTO sys_role_menus (role_id, menu_id, created_at) 
SELECT 1, id, CURDATE() FROM sys_menus WHERE deleted = 0;

-- =============================================
-- 普通用户角色分配基本权限（只读）
-- =============================================
INSERT INTO sys_role_menus (role_id, menu_id, created_at) 
SELECT 2, id, CURDATE() FROM sys_menus 
WHERE deleted = 0 
  AND permission IN ('product:view', 'category:view')
  AND type = 1;

-- =============================================
-- 初始化商品分类数据（示例）
-- =============================================
INSERT INTO categories (name, description, sort_order, parent_id, created_at, updated_at, deleted) VALUES
('电子产品', '各类电子产品', 1, NULL, CURDATE(), CURDATE(), 0),
('服装鞋帽', '服装、鞋子、帽子等', 2, NULL, CURDATE(), CURDATE(), 0),
('图书音像', '图书、音乐、影视等', 3, NULL, CURDATE(), CURDATE(), 0),
('食品饮料', '食品、饮料、零食等', 4, NULL, CURDATE(), CURDATE(), 0),
('家居生活', '家居用品、生活用品', 5, NULL, CURDATE(), CURDATE(), 0);

-- 电子产品子分类
INSERT INTO categories (name, description, sort_order, parent_id, created_at, updated_at, deleted) VALUES
('手机通讯', '手机、配件等', 1, 1, CURDATE(), CURDATE(), 0),
('电脑办公', '电脑、办公设备', 2, 1, CURDATE(), CURDATE(), 0),
('数码影音', '相机、耳机等', 3, 1, CURDATE(), CURDATE(), 0);

-- =============================================
-- 初始化示例商品数据
-- =============================================
INSERT INTO products (name, description, price, stock, image_url, sku, status, category_id, created_at, updated_at, deleted) VALUES
('iPhone 15 Pro', 'Apple iPhone 15 Pro 256GB 深空黑色', 8999.00, 100, 'https://via.placeholder.com/400x400?text=iPhone+15+Pro', 'IP15P-256-BLK', 'ACTIVE', 6, CURDATE(), CURDATE(), 0),
('MacBook Pro 14', 'Apple MacBook Pro 14英寸 M3芯片', 14999.00, 50, 'https://via.placeholder.com/400x400?text=MacBook+Pro', 'MBP14-M3-512', 'ACTIVE', 7, CURDATE(), CURDATE(), 0),
('AirPods Pro 2', 'Apple AirPods Pro 第二代 主动降噪', 1899.00, 200, 'https://via.placeholder.com/400x400?text=AirPods+Pro', 'APP2-WHT', 'ACTIVE', 8, CURDATE(), CURDATE(), 0),
('iPad Air', 'Apple iPad Air 11英寸 M2芯片 128GB', 4799.00, 80, 'https://via.placeholder.com/400x400?text=iPad+Air', 'IPA-M2-128', 'ACTIVE', 7, CURDATE(), CURDATE(), 0),
('Apple Watch Series 9', 'Apple Watch Series 9 GPS 45mm', 3199.00, 120, 'https://via.placeholder.com/400x400?text=Apple+Watch', 'AWS9-45-GPS', 'ACTIVE', 6, CURDATE(), CURDATE(), 0);

-- =============================================
-- 数据库初始化完成
-- =============================================
-- 说明：
-- 1. 管理员账户由应用启动时 DataInitializer 自动创建
--    用户名: admin
--    密码: Admin@123
-- 2. 管理员拥有所有菜单和按钮权限
-- 3. 普通用户只有查看商品和分类的权限
-- 4. 所有表使用 DATE 类型存储时间
-- 5. 所有表使用逻辑删除（deleted 字段）
-- 6. 系统表使用 sys_ 前缀，业务表不使用前缀

-- =============================================
-- 验证数据
-- =============================================
SELECT '=== 数据库表列表 ===' AS '';
SHOW TABLES;

SELECT '=== 系统角色 ===' AS '';
SELECT id, name, code, description, status FROM sys_roles WHERE deleted = 0;

SELECT '=== 系统菜单（一级） ===' AS '';
SELECT id, name, path, icon, type, sort_order FROM sys_menus WHERE parent_id IS NULL AND deleted = 0 ORDER BY sort_order;

SELECT '=== 商品分类（一级） ===' AS '';
SELECT id, name, description, sort_order FROM categories WHERE parent_id IS NULL AND deleted = 0 ORDER BY sort_order;

SELECT '=== 商品列表 ===' AS '';
SELECT id, name, price, stock, status, sku FROM products WHERE deleted = 0 LIMIT 5;

SELECT '=== 数据统计 ===' AS '';
SELECT 
    (SELECT COUNT(*) FROM sys_roles WHERE deleted = 0) AS '角色数',
    (SELECT COUNT(*) FROM sys_menus WHERE deleted = 0) AS '菜单数',
    (SELECT COUNT(*) FROM categories WHERE deleted = 0) AS '分类数',
    (SELECT COUNT(*) FROM products WHERE deleted = 0) AS '商品数';

-- =============================================
-- 初始化完成！
-- =============================================

