-- =============================================
-- ProjectAn01 初始化数据脚本
-- 执行前请确保已运行 schema.sql
-- =============================================

USE an01;

-- =============================================
-- 初始化角色
-- =============================================
INSERT IGNORE INTO roles (name, description, created_at, updated_at, created_by, deleted)
VALUES
    ('ROLE_USER',      '普通用户',   CURDATE(), CURDATE(), 'system', 0),
    ('ROLE_ADMIN',     '系统管理员', CURDATE(), CURDATE(), 'system', 0),
    ('ROLE_MODERATOR', '内容审核员', CURDATE(), CURDATE(), 'system', 0);

-- =============================================
-- 初始化商品分类（根分类）
-- =============================================
INSERT IGNORE INTO categories (name, description, sort_order, parent_id, created_at, updated_at, created_by, deleted)
VALUES
    ('电子产品', '手机、电脑、配件等电子设备',   1, NULL, CURDATE(), CURDATE(), 'system', 0),
    ('服装鞋帽', '男女服装、鞋类、帽子配饰',     2, NULL, CURDATE(), CURDATE(), 'system', 0),
    ('家居生活', '家具、厨具、家居装饰',         3, NULL, CURDATE(), CURDATE(), 'system', 0),
    ('图书文具', '书籍、办公文具、学习用品',     4, NULL, CURDATE(), CURDATE(), 'system', 0),
    ('运动户外', '运动器材、户外装备、健身用品', 5, NULL, CURDATE(), CURDATE(), 'system', 0);

-- =============================================
-- 初始化子分类
-- =============================================
INSERT IGNORE INTO categories (name, description, sort_order, parent_id, created_at, updated_at, created_by, deleted)
VALUES
    ('手机',   '智能手机',   1, 1, CURDATE(), CURDATE(), 'system', 0),
    ('笔记本', '笔记本电脑', 2, 1, CURDATE(), CURDATE(), 'system', 0),
    ('耳机',   '有线/无线耳机', 3, 1, CURDATE(), CURDATE(), 'system', 0),
    ('男装',   '男士服装',   1, 2, CURDATE(), CURDATE(), 'system', 0),
    ('女装',   '女士服装',   2, 2, CURDATE(), CURDATE(), 'system', 0);

-- =============================================
-- 初始化管理员账号
-- 密码: Admin@123 (BCrypt 加密)
-- =============================================
INSERT IGNORE INTO users
    (username, email, password, full_name, enabled, account_non_locked, created_at, updated_at, created_by, deleted)
VALUES
    ('admin',
     'admin@example.com',
     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBpHNKJAZOJXdm',
     '系统管理员',
     1, 1, CURDATE(), CURDATE(), 'system', 0);

-- 普通测试用户 密码: User@123
INSERT IGNORE INTO users
    (username, email, password, full_name, enabled, account_non_locked, created_at, updated_at, created_by, deleted)
VALUES
    ('testuser',
     'testuser@example.com',
     '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO08IfHjQZ6',
     '测试用户',
     1, 1, CURDATE(), CURDATE(), 'system', 0);

-- =============================================
-- 绑定用户角色
-- =============================================
-- admin -> ROLE_ADMIN + ROLE_USER
INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'admin' AND r.name IN ('ROLE_ADMIN', 'ROLE_USER');

-- testuser -> ROLE_USER
INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'testuser' AND r.name = 'ROLE_USER';

-- =============================================
-- 初始化示例商品
-- =============================================
INSERT IGNORE INTO products
    (name, description, price, stock, image_url, sku, status, category_id, created_at, updated_at, created_by, deleted)
VALUES
    ('iPhone 15 Pro',
     '苹果最新旗舰手机，A17 Pro 芯片，钛金属边框，支持 USB-C 接口，4800万像素主摄。',
     8999.00, 50,
     'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400',
     'IPHONE-15-PRO-001', 'ACTIVE', 6, CURDATE(), CURDATE(), 'admin', 0),

    ('MacBook Pro 14寸 M3',
     '搭载 Apple M3 芯片，16GB 内存，512GB SSD，14.2寸 Liquid Retina XDR 显示屏。',
     14999.00, 30,
     'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
     'MBP-14-M3-001', 'ACTIVE', 7, CURDATE(), CURDATE(), 'admin', 0),

    ('Sony WH-1000XM5 降噪耳机',
     '业界领先主动降噪技术，30小时续航，折叠设计，支持多设备快速切换。',
     2499.00, 100,
     'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
     'SONY-WH1000XM5-001', 'ACTIVE', 8, CURDATE(), CURDATE(), 'admin', 0),

    ('Nike Air Max 270',
     '经典气垫跑鞋，最大气垫单元，超轻网布鞋面，全天候舒适穿着体验。',
     899.00, 200,
     'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
     'NIKE-AIRMAX270-001', 'ACTIVE', 2, CURDATE(), CURDATE(), 'admin', 0),

    ('小米智能台灯 Pro',
     '支持米家APP控制，2700K-6500K色温调节，无频闪护眼认证，Type-C充电。',
     299.00, 300,
     'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400',
     'MI-LAMP-PRO-001', 'ACTIVE', 3, CURDATE(), CURDATE(), 'admin', 0),

    ('《深入理解Java虚拟机》第3版',
     '周志明著，JVM权威之作，涵盖内存管理、GC算法、JIT编译、类加载机制。',
     129.00, 500,
     'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
     'BOOK-JVM-3ED-001', 'ACTIVE', 4, CURDATE(), CURDATE(), 'admin', 0),

    ('三星 Galaxy S24 Ultra',
     '内置 S Pen，200MP 主摄，骁龙8 Gen3，12GB RAM，5000mAh 大电池。',
     9499.00, 40,
     'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
     'SAMSUNG-S24U-001', 'ACTIVE', 6, CURDATE(), CURDATE(), 'admin', 0),

    ('优衣库 摇粒绒外套',
     '经典摇粒绒材质，保暖舒适，多色可选，男女同款，适合秋冬季节。',
     199.00, 1000,
     'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400',
     'UQ-FLEECE-001', 'ACTIVE', 9, CURDATE(), CURDATE(), 'admin', 0);

-- =============================================
-- 确认初始化结果
-- =============================================
SELECT '角色数量' AS item, COUNT(*) AS count FROM roles
UNION ALL
SELECT '用户数量', COUNT(*) FROM users
UNION ALL
SELECT '分类数量', COUNT(*) FROM categories
UNION ALL
SELECT '商品数量', COUNT(*) FROM products;

