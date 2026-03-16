-- =============================================
-- 数据库时间格式统一迁移脚本
-- 将所有 DATETIME(6) 改为 DATE 格式
-- =============================================

-- 1. 修改 users 表
ALTER TABLE users 
    MODIFY COLUMN created_at DATE NOT NULL COMMENT '注册时间',
    MODIFY COLUMN updated_at DATE COMMENT '最后修改时间';

-- 2. 修改 roles 表
ALTER TABLE roles 
    MODIFY COLUMN created_at DATE NOT NULL COMMENT '创建时间',
    MODIFY COLUMN updated_at DATE COMMENT '最后修改时间';

-- 3. 修改 categories 表
ALTER TABLE categories 
    MODIFY COLUMN created_at DATE NOT NULL COMMENT '创建时间',
    MODIFY COLUMN updated_at DATE COMMENT '最后修改时间';

-- 4. 修改 products 表
ALTER TABLE products 
    MODIFY COLUMN created_at DATE NOT NULL COMMENT '创建时间',
    MODIFY COLUMN updated_at DATE COMMENT '最后修改时间';

-- 5. 修改 user_roles 表（如果有时间字段）
-- ALTER TABLE user_roles 
--     MODIFY COLUMN created_at DATE COMMENT '创建时间';

-- 6. 修改 role_menus 表（新增的表）
ALTER TABLE role_menus 
    MODIFY COLUMN created_at DATE COMMENT '创建时间';

-- 7. 修改 menus 表（新增的表）
ALTER TABLE menus 
    MODIFY COLUMN created_at DATE NOT NULL COMMENT '创建时间',
    MODIFY COLUMN updated_at DATE COMMENT '最后修改时间';

