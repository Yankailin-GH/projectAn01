-- 角色表
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL UNIQUE COMMENT '角色名称',
    code VARCHAR(64) NOT NULL UNIQUE COMMENT '角色编码',
    description VARCHAR(255) COMMENT '角色描述',
    status INT DEFAULT 1 COMMENT '状态：0=禁用，1=启用',
    created_at DATE NOT NULL COMMENT '创建时间',
    updated_at DATE COMMENT '最后修改时间',
    deleted INT DEFAULT 0,
    INDEX idx_code (code),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- 菜单表（包含菜单和按钮）
CREATE TABLE IF NOT EXISTS menus (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL COMMENT '菜单名称',
    path VARCHAR(255) COMMENT '路由路径',
    icon VARCHAR(64) COMMENT '图标',
    type INT NOT NULL DEFAULT 1 COMMENT '类型：1=菜单，2=按钮',
    parent_id BIGINT COMMENT '父菜单ID',
    sort_order INT DEFAULT 0 COMMENT '排序',
    permission VARCHAR(255) COMMENT '权限标识',
    component VARCHAR(255) COMMENT '组件路径',
    created_at DATE NOT NULL COMMENT '创建时间',
    updated_at DATE COMMENT '最后修改时间',
    deleted INT DEFAULT 0,
    INDEX idx_parent_id (parent_id),
    INDEX idx_type (type),
    INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜单表';

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS user_roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    created_at DATE COMMENT '创建时间',
    UNIQUE KEY uk_user_role (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

-- 角色菜单关联表
CREATE TABLE IF NOT EXISTS role_menus (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id BIGINT NOT NULL,
    menu_id BIGINT NOT NULL,
    created_at DATE COMMENT '创建时间',
    UNIQUE KEY uk_role_menu (role_id, menu_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE,
    INDEX idx_role_id (role_id),
    INDEX idx_menu_id (menu_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色菜单关联表';

-- 初始化管理员角色
INSERT INTO roles (name, code, description, status, created_at, updated_at) VALUES 
('管理员', 'ADMIN', '系统管理员', 1, CURDATE(), CURDATE()),
('用户', 'USER', '普通用户', 1, CURDATE(), CURDATE());

-- 初始化菜单数据
INSERT INTO menus (name, path, icon, type, parent_id, sort_order, permission, component, created_at, updated_at) VALUES
('系统管理', '/system', 'setting', 1, NULL, 0, NULL, NULL, CURDATE(), CURDATE()),
('用户管理', '/system/users', 'user', 1, 1, 1, 'user:view', '/system/User', CURDATE(), CURDATE()),
('新增用户', NULL, 'plus', 2, 2, 0, 'user:add', NULL, CURDATE(), CURDATE()),
('编辑用户', NULL, 'edit', 2, 2, 1, 'user:edit', NULL, CURDATE(), CURDATE()),
('删除用户', NULL, 'delete', 2, 2, 2, 'user:delete', NULL, CURDATE(), CURDATE()),
('角色管理', '/system/roles', 'team', 1, 1, 3, 'role:view', '/system/Role', CURDATE(), CURDATE()),
('新增角色', NULL, 'plus', 2, 6, 4, 'role:add', NULL, CURDATE(), CURDATE()),
('编辑角色', NULL, 'edit', 2, 6, 5, 'role:edit', NULL, CURDATE(), CURDATE()),
('删除角色', NULL, 'delete', 2, 6, 6, 'role:delete', NULL, CURDATE(), CURDATE()),
('菜单管理', '/system/menus', 'menu', 1, 1, 7, 'menu:view', '/system/Menu', CURDATE(), CURDATE()),
('新增菜单', NULL, 'plus', 2, 10, 8, 'menu:add', NULL, CURDATE(), CURDATE()),
('编辑菜单', NULL, 'edit', 2, 10, 9, 'menu:edit', NULL, CURDATE(), CURDATE()),
('删除菜单', NULL, 'delete', 2, 10, 10, 'menu:delete', NULL, CURDATE(), CURDATE());

-- 管理员角色分配所有菜单
INSERT INTO role_menus (role_id, menu_id) 
SELECT 1, id FROM menus WHERE deleted = 0;

