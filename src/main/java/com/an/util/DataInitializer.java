package com.an.util;

import com.an.entity.Menu;
import com.an.entity.Role;
import com.an.entity.User;
import com.an.mapper.MenuMapper;
import com.an.mapper.RoleMapper;
import com.an.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final RoleMapper roleMapper;
    private final UserMapper userMapper;
    private final MenuMapper menuMapper;
    private final PasswordEncoder passwordEncoder;
    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        initRoles();
        initMenus();
        initAdminUser();
        assignMenusToRoles();
    }

    private void initRoles() {
        for (Role.RoleName roleName : Role.RoleName.values()) {
            // 使用 code 字段查询（去掉 ROLE_ 前缀）
            String code = roleName.name().replace("ROLE_", "");
            if (roleMapper.countByCode(code) == 0) {
                Role role = new Role();
                role.setName(roleName.desc);  // 中文名称
                role.setCode(code);           // 英文编码（ADMIN, USER）
                role.setDescription(roleName.desc);
                role.setStatus(1);            // 启用状态
                roleMapper.insert(role);
                log.info("初始化角色: {} ({})", roleName.desc, code);
            }
        }
    }

    private void initAdminUser() {
        if (userMapper.countByUsername("admin") == 0) {
            User admin = User.builder()
                    .username("admin")
                    .email("admin@example.com")
                    .password(passwordEncoder.encode("Admin@123"))
                    .fullName("系统管理员")
                    .build();
            userMapper.insert(admin);

            // 使用 code 查询角色
            Role adminRole = roleMapper.selectByCode("ADMIN");
            Role userRole  = roleMapper.selectByCode("USER");
            if (adminRole != null) {
                jdbcTemplate.update(
                    "INSERT IGNORE INTO sys_user_roles(user_id,role_id) VALUES(?,?)",
                    admin.getId(), adminRole.getId());
            }
            if (userRole != null) {
                jdbcTemplate.update(
                    "INSERT IGNORE INTO sys_user_roles(user_id,role_id) VALUES(?,?)",
                    admin.getId(), userRole.getId());
            }
            log.info("初始化管理员账户: admin / Admin@123");
        }
    }

    private void initMenus() {
        // 检查是否已有菜单数据
        Long count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM sys_menus WHERE deleted = 0", Long.class);
        if (count != null && count > 0) {
            log.info("菜单数据已存在，跳过初始化");
            return;
        }

        log.info("开始初始化菜单数据...");
        List<Menu> menus = new ArrayList<>();

        // 一级菜单
        menus.add(createMenu(1L, "系统管理", "/system", "SettingOutlined", 1, null, 1, null, "Layout"));
        menus.add(createMenu(2L, "商品管理", "/product", "ShoppingOutlined", 1, null, 2, null, "Layout"));
        menus.add(createMenu(3L, "订单管理", "/order", "FileTextOutlined", 1, null, 3, null, "Layout"));
        menus.add(createMenu(4L, "用户中心", "/profile", "UserOutlined", 1, null, 4, null, "Layout"));

        // 二级菜单 - 系统管理
        menus.add(createMenu(101L, "用户管理", "/admin/users", "TeamOutlined", 1, 1L, 1, "system:user:list", "/admin/users"));
        menus.add(createMenu(102L, "角色管理", "/admin/roles", "SafetyOutlined", 1, 1L, 2, "system:role:list", "/admin/roles"));
        menus.add(createMenu(103L, "菜单管理", "/admin/menus", "MenuOutlined", 1, 1L, 3, "system:menu:list", "/admin/menus"));

        // 二级菜单 - 商品管理
        menus.add(createMenu(201L, "商品列表", "/admin/products", "UnorderedListOutlined", 1, 2L, 1, "product:list", "/admin/products"));
        menus.add(createMenu(202L, "商品浏览", "/products", "AppstoreOutlined", 1, 2L, 2, "product:view", "/products"));

        // 二级菜单 - 订单管理
        menus.add(createMenu(301L, "订单列表", "/admin/orders", "OrderedListOutlined", 1, 3L, 1, "order:list", "/admin/orders"));

        // 二级菜单 - 用户中心
        menus.add(createMenu(401L, "个人信息", "/profile/info", "IdcardOutlined", 1, 4L, 1, "profile:info", "/profile/info"));
        menus.add(createMenu(402L, "修改密码", "/profile/password", "LockOutlined", 1, 4L, 2, "profile:password", "/profile/password"));

        // 按钮权限 - 用户管理
        menus.add(createMenu(10101L, "新增用户", null, null, 2, 101L, 1, "system:user:add", null));
        menus.add(createMenu(10102L, "编辑用户", null, null, 2, 101L, 2, "system:user:edit", null));
        menus.add(createMenu(10103L, "删除用户", null, null, 2, 101L, 3, "system:user:delete", null));
        menus.add(createMenu(10104L, "重置密码", null, null, 2, 101L, 4, "system:user:reset", null));

        // 按钮权限 - 角色管理
        menus.add(createMenu(10201L, "新增角色", null, null, 2, 102L, 1, "system:role:add", null));
        menus.add(createMenu(10202L, "编辑角色", null, null, 2, 102L, 2, "system:role:edit", null));
        menus.add(createMenu(10203L, "删除角色", null, null, 2, 102L, 3, "system:role:delete", null));
        menus.add(createMenu(10204L, "分配权限", null, null, 2, 102L, 4, "system:role:assign", null));

        // 按钮权限 - 菜单管理
        menus.add(createMenu(10301L, "新增菜单", null, null, 2, 103L, 1, "system:menu:add", null));
        menus.add(createMenu(10302L, "编辑菜单", null, null, 2, 103L, 2, "system:menu:edit", null));
        menus.add(createMenu(10303L, "删除菜单", null, null, 2, 103L, 3, "system:menu:delete", null));

        // 按钮权限 - 商品管理
        menus.add(createMenu(20101L, "新增商品", null, null, 2, 201L, 1, "product:add", null));
        menus.add(createMenu(20102L, "编辑商品", null, null, 2, 201L, 2, "product:edit", null));
        menus.add(createMenu(20103L, "删除商品", null, null, 2, 201L, 3, "product:delete", null));
        menus.add(createMenu(20104L, "上架商品", null, null, 2, 201L, 4, "product:publish", null));
        menus.add(createMenu(20105L, "下架商品", null, null, 2, 201L, 5, "product:unpublish", null));

        // 批量插入
        for (Menu menu : menus) {
            menuMapper.insert(menu);
        }

        log.info("菜单数据初始化完成，共 {} 条", menus.size());
    }

    private Menu createMenu(Long id, String name, String path, String icon, Integer type, 
                           Long parentId, Integer sortOrder, String permission, String component) {
        Menu menu = new Menu();
        menu.setId(id);
        menu.setName(name);
        menu.setPath(path);
        menu.setIcon(icon);
        menu.setType(type);
        menu.setParentId(parentId);
        menu.setSortOrder(sortOrder);
        menu.setPermission(permission);
        menu.setComponent(component);
        return menu;
    }

    private void assignMenusToRoles() {
        Role adminRole = roleMapper.selectByCode("ADMIN");
        Role userRole = roleMapper.selectByCode("USER");

        if (adminRole == null || userRole == null) {
            log.warn("角色不存在，跳过菜单分配");
            return;
        }

        // 检查是否已分配
        Long adminMenuCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM sys_role_menus WHERE role_id = ?", Long.class, adminRole.getId());
        
        if (adminMenuCount != null && adminMenuCount > 0) {
            log.info("角色菜单已分配，跳过");
            return;
        }

        // ADMIN 角色分配所有菜单
        jdbcTemplate.update(
            "INSERT INTO sys_role_menus (role_id, menu_id) " +
            "SELECT ?, id FROM sys_menus WHERE deleted = 0",
            adminRole.getId()
        );
        log.info("为 ADMIN 角色分配所有菜单权限");

        // USER 角色分配基础菜单（商品查看、订单查看、个人中心）
        Long[] userMenuIds = {2L, 201L, 3L, 301L, 4L, 401L, 402L};
        for (Long menuId : userMenuIds) {
            jdbcTemplate.update(
                "INSERT IGNORE INTO sys_role_menus (role_id, menu_id) VALUES (?, ?)",
                userRole.getId(), menuId
            );
        }
        log.info("为 USER 角色分配基础菜单权限");
    }
}
