package com.an.controller;

import com.an.dto.response.PageResult;
import com.an.dto.response.Result;
import com.an.entity.Role;
import com.an.mapper.RoleMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/roles")
@RequiredArgsConstructor
@Tag(name = "角色管理", description = "角色信息和权限管理")
public class RoleController {

    private final RoleMapper roleMapper;
    private final JdbcTemplate jdbcTemplate;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "分页获取角色列表", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<PageResult<Role>> list(
            @RequestParam(name = "page", defaultValue = "1") int page,
            @RequestParam(name = "size", defaultValue = "20") int size) {

        Page<Role> pageObj = new Page<>(page, size);
        IPage<Role> result = roleMapper.selectPage(pageObj, null);

        PageResult<Role> pageResult = PageResult.<Role>builder()
                .current(result.getCurrent())
                .size(result.getSize())
                .total(result.getTotal())
                .pages(result.getPages())
                .records(result.getRecords())
                .build();

        return Result.ok(pageResult);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "获取角色详情", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Role> getById(@PathVariable Long id) {
        Role role = roleMapper.selectById(id);
        if (role == null) {
            return Result.notFound("角色不存在");
        }
        return Result.ok(role);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "创建角色", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Role> create(@Valid @RequestBody Role role) {
        // 检查角色编码是否已存在
        if (roleMapper.countByCode(role.getCode()) > 0) {
            return Result.error("角色编码已存在");
        }
        // 设置默认状态为启用
        if (role.getStatus() == null) {
            role.setStatus(1);
        }
        roleMapper.insert(role);
        return Result.ok("角色创建成功", role);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "更新角色", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Role> update(@PathVariable Long id, @Valid @RequestBody Role role) {
        Role existing = roleMapper.selectById(id);
        if (existing == null) {
            return Result.notFound("角色不存在");
        }
        
        // 如果修改了角色编码，检查是否重复
        if (!existing.getCode().equals(role.getCode())) {
            if (roleMapper.countByCode(role.getCode()) > 0) {
                return Result.error("角色编码已存在");
            }
        }
        
        role.setId(id);
        roleMapper.updateById(role);
        return Result.ok("角色更新成功", role);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "删除角色", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Void> delete(@PathVariable Long id) {
        Role role = roleMapper.selectById(id);
        if (role == null) {
            return Result.notFound("角色不存在");
        }
        
        // 检查是否有用户使用该角色
        Integer userCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM sys_user_roles WHERE role_id = ?", 
            Integer.class, 
            id
        );
        if (userCount != null && userCount > 0) {
            return Result.error("该角色下还有 " + userCount + " 个用户，无法删除");
        }
        
        // 删除角色的菜单权限
        jdbcTemplate.update("DELETE FROM sys_role_menus WHERE role_id = ?", id);
        
        // 删除角色
        roleMapper.deleteById(id);
        return Result.okMsg("角色删除成功");
    }

    @PutMapping("/{id}/menus")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "分配角色菜单权限", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Void> assignMenus(@PathVariable Long id, @RequestBody Long[] menuIds) {
        // 先删除旧菜单权限
        jdbcTemplate.update("DELETE FROM sys_role_menus WHERE role_id = ?", id);
        // 插入新菜单权限
        for (Long menuId : menuIds) {
            jdbcTemplate.update("INSERT INTO sys_role_menus(role_id, menu_id) VALUES(?, ?)", id, menuId);
        }
        return Result.okMsg("菜单权限分配成功");
    }
}
