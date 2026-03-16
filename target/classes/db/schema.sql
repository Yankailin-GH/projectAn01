-- =============================================
-- ProjectAn01 数据库初始化脚本
-- 数据库: MySQL 8.0
-- 字符集: utf8mb4
-- =============================================

CREATE DATABASE IF NOT EXISTS project_an01
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE an01;

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
    deleted     TINYINT(1)   NOT NULL DEFAULT 0      COMMENT '逻辑删除（0=正常,1=已删除）',
    PRIMARY KEY (id),
    KEY idx_parent_id (parent_id),
    KEY idx_sort_order (sort_order),
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_id) REFERENCES categories (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品分类表';

-- =============================================
-- 角色表
-- =============================================
CREATE TABLE IF NOT EXISTS roles (
    id          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    name        VARCHAR(50) NOT NULL                COMMENT '角色名称（ROLE_USER/ROLE_ADMIN/ROLE_MODERATOR）',
    description VARCHAR(200)                        COMMENT '角色描述',
    -- 审计字段
    created_at  DATE        NOT NULL                COMMENT '创建时间',
    updated_at  DATE                                COMMENT '最后修改时间',
    created_by  VARCHAR(100)                        COMMENT '创建人',
    updated_by  VARCHAR(100)                        COMMENT '最后修改人',
    deleted     TINYINT(1)  NOT NULL DEFAULT 0      COMMENT '逻辑删除',
    PRIMARY KEY (id),
    UNIQUE KEY uk_role_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- =============================================
-- 用户表
-- =============================================
CREATE TABLE IF NOT EXISTS users (
    id                BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    username          VARCHAR(50)  NOT NULL                COMMENT '用户名（唯一）',
    email             VARCHAR(100) NOT NULL                COMMENT '邮箱（唯一）',
    password          VARCHAR(255) NOT NULL                COMMENT '密码（BCrypt加密）',
    full_name         VARCHAR(100)                         COMMENT '真实姓名',
    phone             VARCHAR(20)                          COMMENT '手机号',
    avatar_url        VARCHAR(500)                         COMMENT '头像URL',
    enabled           TINYINT(1)   NOT NULL DEFAULT 1      COMMENT '账号是否启用',
    account_non_locked TINYINT(1)  NOT NULL DEFAULT 1      COMMENT '账号是否未锁定',
    -- 审计字段
    created_at        DATE         NOT NULL                COMMENT '注册时间',
    updated_at        DATE                                 COMMENT '最后修改时间',
    created_by        VARCHAR(100)                         COMMENT '创建人',
    updated_by        VARCHAR(100)                         COMMENT '最后修改人',
    deleted           TINYINT(1)   NOT NULL DEFAULT 0      COMMENT '逻辑删除',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email),
    KEY idx_enabled (enabled),
    KEY idx_deleted (deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- =============================================
-- 用户角色关联表（多对多）
-- =============================================
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

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
    deleted     TINYINT(1)     NOT NULL DEFAULT 0      COMMENT '逻辑删除',
    PRIMARY KEY (id),
    UNIQUE KEY uk_sku (sku),
    KEY idx_status (status),
    KEY idx_category_id (category_id),
    KEY idx_price (price),
    KEY idx_deleted (deleted),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品表';

