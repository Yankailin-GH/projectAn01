-- 添加 status 字段到 users 表
ALTER TABLE users ADD COLUMN status INT DEFAULT 1 COMMENT '状态：0=禁用，1=启用' AFTER enabled;

