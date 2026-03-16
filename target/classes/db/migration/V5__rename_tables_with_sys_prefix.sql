-- =============================================
-- V5: 重命名系统管理表，添加 sys_ 前缀
-- =============================================
-- 说明：将 users, roles, menus 等系统管理表重命名为 sys_users, sys_roles, sys_menus
-- 执行前请备份数据库！

-- 1. 删除外键约束（需要先删除才能重命名表）
ALTER TABLE user_roles DROP FOREIGN KEY user_roles_ibfk_1;
ALTER TABLE user_roles DROP FOREIGN KEY user_roles_ibfk_2;
ALTER TABLE role_menus DROP FOREIGN KEY role_menus_ibfk_1;
ALTER TABLE role_menus DROP FOREIGN KEY role_menus_ibfk_2;

-- 2. 重命名表
RENAME TABLE users TO sys_users;
RENAME TABLE roles TO sys_roles;
RENAME TABLE menus TO sys_menus;
RENAME TABLE user_roles TO sys_user_roles;
RENAME TABLE role_menus TO sys_role_menus;

-- 3. 重新添加外键约束
ALTER TABLE sys_user_roles 
    ADD CONSTRAINT fk_sys_user_roles_user FOREIGN KEY (user_id) REFERENCES sys_users(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_sys_user_roles_role FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE;

ALTER TABLE sys_role_menus 
    ADD CONSTRAINT fk_sys_role_menus_role FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_sys_role_menus_menu FOREIGN KEY (menu_id) REFERENCES sys_menus(id) ON DELETE CASCADE;

-- 4. 更新表注释
ALTER TABLE sys_users COMMENT='系统用户表';
ALTER TABLE sys_roles COMMENT='系统角色表';
ALTER TABLE sys_menus COMMENT='系统菜单表';
ALTER TABLE sys_user_roles COMMENT='系统用户角色关联表';
ALTER TABLE sys_role_menus COMMENT='系统角色菜单关联表';

