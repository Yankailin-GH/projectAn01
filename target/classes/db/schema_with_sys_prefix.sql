-- =============================================
-- ProjectAn01 数据库完整初始化脚本（带 sys_ 前缀）
-- 数据库: MySQL 8.0
-- 字符集: utf8mb4
-- =============================================

CREATE DATABASE IF NOT EXISTS project_an01
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE project_an01;

-- =============================================
-- 系统用户表
-- =============================================
CREATE TABLE IF NOT EXISTS sys_users (
    id                BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    username          VARCHAR(50)  NOT NULL                COMMENT '用户名（唯一）',
    email             VARCHAR(100) NOT NULL                COMMENT '邮箱（唯一）',
    password          VARCHAR(255) NOT NULL                COMMENT '密码（BCrypt加密）',
    full_name         VARCHAR(100)                         COMMENT '真实姓名',
    phone             VARCHAR(20)                          COMMENT '手机号',
    avatar_url        VARCHAR(500)                         COMMENT '头像URL',
    enabled           TINYINT(1)   NOT NULL DEFAULT 1      COMMENT '账号是否启用',
    status            INT          NOT NULL DEFAULT 1      COMMENT '状态：0=禁用，1=启用',
    account_non_locked TINYINT(1)  NOT NULL DEFAULT 1      COMMENT '账号是否未锁定',
    -- 审计字段
    created_at        DATE         NOT NULL                COMMENT '注册时间',
    updated_at        DATE                                 COMMENT '最后修改时间',
    created_by        VARCHAR(100)                         COMMENT '创建人',
    updated_by        VARCHAR(100)                         COMMENT '最后修改人',
    deleted           INT          NOT NULL DEFAULT 0      COMMENT '逻辑删除（0=正常,1=已删除）',
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
CREATE TABLE IF NOT EXISTS sys_roles (
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
CREATE TABLE IF NOT EXISTS sys_menus (
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
CREATE TABLE IF NOT EXISTS sys_user_roles (
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
CREATE TABLE IF NOT EXISTS sys_role_menus (
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
CREATE TABLE IF NOT EXISTS categories (
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
CREATE TABLE IF NOT EXISTS products (
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

-- =============================================
-- 初始化系统角色数据
-- =============================================
INSERT INTO sys_roles (name, code, description, status, created_at, updated_at) VALUES 
('管理员', 'ADMIN', '系统管理员', 1, CURDATE(), CURDATE()),
('用户', 'USER', '普通用户', 1, CURDATE(), CURDATE()),
('内容审核员', 'MODERATOR', '内容审核员', 1, CURDATE(), CURDATE());

-- =============================================
-- 初始化系统菜单数据
-- =============================================
INSERT INTO sys_menus (name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at) VALUES
-- 一级菜单
('系统管理', '/system', 'setting', 1, NULL, 0, NULL, NULL, CURDATE(), CURDATE()),
-- 二级菜单
('用户管理', '/admin/users', 'user', 1, 1, 1, 'user:view', '/admin/users', CURDATE(), CURDATE()),
('角色管理', '/admin/roles', 'team', 1, 1, 2, 'role:view', '/admin/roles', CURDATE(), CURDATE()),
('菜单管理', '/admin/menus', 'menu', 1, 1, 3, 'menu:view', '/admin/menus', CURDATE(), CURDATE()),
-- 用户管理按钮
('新增用户', NULL, 'plus', 2, 2, 0, 'user:add', NULL, CURDATE(), CURDATE()),
('编辑用户', NULL, 'edit', 2, 2, 1, 'user:edit', NULL, CURDATE(), CURDATE()),
('删除用户', NULL, 'delete', 2, 2, 2, 'user:delete', NULL, CURDATE(), CURDATE()),
-- 角色管理按钮
('新增角色', NULL, 'plus', 2, 3, 0, 'role:add', NULL, CURDATE(), CURDATE()),
('编辑角色', NULL, 'edit', 2, 3, 1, 'role:edit', NULL, CURDATE(), CURDATE()),
('删除角色', NULL, 'delete', 2, 3, 2, 'role:delete', NULL, CURDATE(), CURDATE()),
-- 菜单管理按钮
('新增菜单', NULL, 'plus', 2, 4, 0, 'menu:add', NULL, CURDATE(), CURDATE()),
('编辑菜单', NULL, 'edit', 2, 4, 1, 'menu:edit', NULL, CURDATE(), CURDATE()),
('删除菜单', NULL, 'delete', 2, 4, 2, 'menu:delete', NULL, CURDATE(), CURDATE());

-- =============================================
-- 初始化管理员用户
-- =============================================
-- 密码: Admin@123 (BCrypt加密后的值，需要应用启动时由 DataInitializer 创建)
-- 注意：实际密码由 DataInitializer 在应用启动时创建

-- =============================================
-- 管理员角色分配所有菜单权限
-- =============================================
INSERT INTO sys_role_menus (role_id, menu_id, created_at) 
SELECT 1, id, CURDATE() FROM sys_menus WHERE deleted = 0;

