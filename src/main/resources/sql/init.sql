-- =============================================
-- ProjectAn01 数据库初始化脚本
-- 日期: 2026-03-16
-- 数据库: MySQL 8.0+
-- 字符集: utf8mb4
-- 说明: 包含完整的数据库结构和初始数据
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
-- 初始化系统角色
-- =============================================
INSERT IGNORE INTO sys_roles (name, code, description, status, created_at, updated_at, created_by)
VALUES
    ('管理员', 'ADMIN', '系统管理员', 1, CURDATE(), CURDATE(), 'system'),
    ('用户', 'USER', '普通用户', 1, CURDATE(), CURDATE(), 'system'),
    ('内容审核员', 'MODERATOR', '内容审核员', 1, CURDATE(), CURDATE(), 'system');

-- =============================================
-- 初始化系统菜单
-- =============================================
INSERT IGNORE INTO sys_menus (name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at, created_by)
VALUES
    ('系统管理', '/system', 'setting', 1, NULL, 1, NULL, NULL, CURDATE(), CURDATE(), 'system'),
    ('商品管理', '/product', 'shopping', 1, NULL, 2, NULL, NULL, CURDATE(), CURDATE(), 'system'),
    ('订单管理', '/order', 'file-text', 1, NULL, 3, NULL, NULL, CURDATE(), CURDATE(), 'system'),
    ('用户中心', '/profile', 'user', 1, NULL, 4, NULL, NULL, CURDATE(), CURDATE(), 'system'),
    ('用户管理', '/system/users', 'team', 1, 1, 1, 'system:user:list', '/system/users', CURDATE(), CURDATE(), 'system'),
    ('角色管理', '/system/roles', 'safety', 1, 1, 2, 'system:role:list', '/system/roles', CURDATE(), CURDATE(), 'system'),
    ('菜单管理', '/system/menus', 'menu', 1, 1, 3, 'system:menu:list', '/system/menus', CURDATE(), CURDATE(), 'system'),
    ('商品列表', '/product/list', 'unordered-list', 1, 2, 1, 'product:list', '/product/list', CURDATE(), CURDATE(), 'system'),
    ('分类管理', '/product/category', 'appstore', 1, 2, 2, 'product:category:list', '/product/category', CURDATE(), CURDATE(), 'system'),
    ('订单列表', '/order/list', 'ordered-list', 1, 3, 1, 'order:list', '/order/list', CURDATE(), CURDATE(), 'system'),
    ('个人信息', '/profile/info', 'idcard', 1, 4, 1, 'profile:info', '/profile/info', CURDATE(), CURDATE(), 'system'),
    ('修改密码', '/profile/password', 'lock', 1, 4, 2, 'profile:password', '/profile/password', CURDATE(), CURDATE(), 'system'),
    ('新增用户', NULL, NULL, 2, 5, 1, 'system:user:add', NULL, CURDATE(), CURDATE(), 'system'),
    ('编辑用户', NULL, NULL, 2, 5, 2, 'system:user:edit', NULL, CURDATE(), CURDATE(), 'system'),
    ('删除用户', NULL, NULL, 2, 5, 3, 'system:user:delete', NULL, CURDATE(), CURDATE(), 'system'),
    ('重置密码', NULL, NULL, 2, 5, 4, 'system:user:reset', NULL, CURDATE(), CURDATE(), 'system'),
    ('新增角色', NULL, NULL, 2, 6, 1, 'system:role:add', NULL, CURDATE(), CURDATE(), 'system'),
    ('编辑角色', NULL, NULL, 2, 6, 2, 'system:role:edit', NULL, CURDATE(), CURDATE(), 'system'),
    ('删除角色', NULL, NULL, 2, 6, 3, 'system:role:delete', NULL, CURDATE(), CURDATE(), 'system'),
    ('分配权限', NULL, NULL, 2, 6, 4, 'system:role:assign', NULL, CURDATE(), CURDATE(), 'system'),
    ('新增菜单', NULL, NULL, 2, 7, 1, 'system:menu:add', NULL, CURDATE(), CURDATE(), 'system'),
    ('编辑菜单', NULL, NULL, 2, 7, 2, 'system:menu:edit', NULL, CURDATE(), CURDATE(), 'system'),
    ('删除菜单', NULL, NULL, 2, 7, 3, 'system:menu:delete', NULL, CURDATE(), CURDATE(), 'system'),
    ('新增商品', NULL, NULL, 2, 8, 1, 'product:add', NULL, CURDATE(), CURDATE(), 'system'),
    ('编辑商品', NULL, NULL, 2, 8, 2, 'product:edit', NULL, CURDATE(), CURDATE(), 'system'),
    ('删除商品', NULL, NULL, 2, 8, 3, 'product:delete', NULL, CURDATE(), CURDATE(), 'system'),
    ('上架商品', NULL, NULL, 2, 8, 4, 'product:publish', NULL, CURDATE(), CURDATE(), 'system'),
    ('下架商品', NULL, NULL, 2, 8, 5, 'product:unpublish', NULL, CURDATE(), CURDATE(), 'system');

-- =============================================
-- 初始化商品分类
-- =============================================
INSERT IGNORE INTO categories (name, description, sort_order, parent_id, created_at, updated_at, created_by)
VALUES
    ('电子产品', '手机、电脑、配件等电子设备', 1, NULL, CURDATE(), CURDATE(), 'system'),
    ('服装鞋帽', '男女服装、鞋类、帽子配饰', 2, NULL, CURDATE(), CURDATE(), 'system'),
    ('家居生活', '家具、厨具、家居装饰', 3, NULL, CURDATE(), CURDATE(), 'system'),
    ('图书文具', '书籍、办公文具、学习用品', 4, NULL, CURDATE(), CURDATE(), 'system'),
    ('运动户外', '运动器材、户外装备、健身用品', 5, NULL, CURDATE(), CURDATE(), 'system'),
    ('手机', '智能手机', 1, 1, CURDATE(), CURDATE(), 'system'),
    ('笔记本', '笔记本电脑', 2, 1, CURDATE(), CURDATE(), 'system'),
    ('耳机', '有线/无线耳机', 3, 1, CURDATE(), CURDATE(), 'system'),
    ('男装', '男士服装', 1, 2, CURDATE(), CURDATE(), 'system'),
    ('女装', '女士服装', 2, 2, CURDATE(), CURDATE(), 'system');

-- =============================================
-- 初始化示例商品
-- =============================================
INSERT IGNORE INTO products (name, description, price, stock, image_url, sku, status, category_id, created_at, updated_at, created_by)
VALUES
    ('iPhone 15 Pro', '苹果最新旗舰手机，A17 Pro 芯片，钛金属边框，支持 USB-C 接口，4800万像素主摄。', 8999.00, 50, 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400', 'IPHONE-15-PRO-001', 'ACTIVE', 6, CURDATE(), CURDATE(), 'system'),
    ('MacBook Pro 14寸 M3', '搭载 Apple M3 芯片，16GB 内存，512GB SSD，14.2寸 Liquid Retina XDR 显示屏。', 14999.00, 30, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400', 'MBP-14-M3-001', 'ACTIVE', 7, CURDATE(), CURDATE(), 'system'),
    ('Sony WH-1000XM5 降噪耳机', '业界领先主动降噪技术，30小时续航，折叠设计，支持多设备快速切换。', 2499.00, 100, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 'SONY-WH1000XM5-001', 'ACTIVE', 8, CURDATE(), CURDATE(), 'system'),
    ('Nike Air Max 270', '经典气垫跑鞋，最大气垫单元，超轻网布鞋面，全天候舒适穿着体验。', 899.00, 200, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400', 'NIKE-AIRMAX270-001', 'ACTIVE', 2, CURDATE(), CURDATE(), 'system'),
    ('小米智能台灯 Pro', '支持米家APP控制，2700K-6500K色温调节，无频闪护眼认证，Type-C充电。', 299.00, 300, 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400', 'MI-LAMP-PRO-001', 'ACTIVE', 3, CURDATE(), CURDATE(), 'system'),
    ('《深入理解Java虚拟机》第3版', '周志明著，JVM权威之作，涵盖内存管理、GC算法、JIT编译、类加载机制。', 129.00, 500, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400', 'BOOK-JVM-3ED-001', 'ACTIVE', 4, CURDATE(), CURDATE(), 'system'),
    ('三星 Galaxy S24 Ultra', '内置 S Pen，200MP 主摄，骁龙8 Gen3，12GB RAM，5000mAh 大电池。', 9499.00, 40, 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400', 'SAMSUNG-S24U-001', 'ACTIVE', 6, CURDATE(), CURDATE(), 'system'),
    ('优衣库 摇粒绒外套', '经典摇粒绒材质，保暖舒适，多色可选，男女同款，适合秋冬季节。', 199.00, 1000, 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400', 'UQ-FLEECE-001', 'ACTIVE', 9, CURDATE(), CURDATE(), 'system');

-- =============================================
-- 为 ADMIN 角色分配所有菜单权限
-- =============================================
INSERT IGNORE INTO sys_role_menus (role_id, menu_id, created_at)
SELECT r.id, m.id, CURDATE()
FROM sys_roles r, sys_menus m
WHERE r.code = 'ADMIN' AND m.deleted = 0;

-- =============================================
-- 为 USER 角色分配基础菜单权限
-- =============================================
INSERT IGNORE INTO sys_role_menus (role_id, menu_id, created_at)
SELECT r.id, m.id, CURDATE()
FROM sys_roles r, sys_menus m
WHERE r.code = 'USER' 
  AND m.id IN (2, 8, 9, 3, 10, 4, 11, 12)
  AND m.deleted = 0;

-- =============================================
-- 初始化完成
-- =============================================
