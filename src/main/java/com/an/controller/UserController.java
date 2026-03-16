package com.an.controller;

import com.an.dto.response.PageResult;
import com.an.dto.response.Result;
import com.an.entity.User;
import com.an.mapper.UserMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
@Tag(name = "用户管理", description = "用户信息管理")
public class UserController {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JdbcTemplate jdbcTemplate;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "分页获取用户列表", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<PageResult<User>> list(
            @RequestParam(name = "page", defaultValue = "1") int page,
            @RequestParam(name = "size", defaultValue = "20") int size,
            @RequestParam(name = "keyword", required = false) String keyword) {

        Page<User> pageObj = new Page<>(page, size);
        IPage<User> result = (keyword != null && !keyword.isBlank())
                ? userMapper.searchUsers(keyword, pageObj)
                : userMapper.selectPage(pageObj, null);

        PageResult<User> pageResult = PageResult.<User>builder()
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
    @Operation(summary = "获取用户详情", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<User> getById(@PathVariable Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            return Result.notFound("用户不存在");
        }
        return Result.ok(user);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "创建用户", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<User> create(@Valid @RequestBody User user) {
        // 检查用户名是否已存在
        if (userMapper.countByUsername(user.getUsername()) > 0) {
            return Result.error("用户名已存在");
        }
        // 检查邮箱是否已存在
        if (userMapper.countByEmail(user.getEmail()) > 0) {
            return Result.error("邮箱已存在");
        }
        // 加密密码
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        // 设置默认状态为启用
        if (user.getStatus() == null) {
            user.setStatus(1);
        }
        userMapper.insert(user);
        return Result.ok("用户创建成功", user);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "更新用户信息", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<User> update(@PathVariable Long id, @Valid @RequestBody User user) {
        User existing = userMapper.selectById(id);
        if (existing == null) {
            return Result.notFound("用户不存在");
        }
        
        // 如果修改了用户名，检查是否重复
        if (!existing.getUsername().equals(user.getUsername())) {
            if (userMapper.countByUsername(user.getUsername()) > 0) {
                return Result.error("用户名已存在");
            }
        }
        
        // 如果修改了邮箱，检查是否重复
        if (!existing.getEmail().equals(user.getEmail())) {
            if (userMapper.countByEmail(user.getEmail()) > 0) {
                return Result.error("邮箱已存在");
            }
        }
        
        user.setId(id);
        // 不允许通过此接口修改密码
        user.setPassword(existing.getPassword());
        userMapper.updateById(user);
        return Result.ok("用户更新成功", user);
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "启用/禁用用户", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Void> toggleStatus(@PathVariable Long id, @RequestParam(name = "status") Integer status) {
        User user = userMapper.selectById(id);
        if (user == null) {
            return Result.notFound("用户不存在");
        }
        
        // 不能禁用自己
        // TODO: 获取当前登录用户ID进行判断
        
        user.setStatus(status);
        userMapper.updateById(user);
        return Result.okMsg(status == 1 ? "用户已启用" : "用户已禁用");
    }

    @PutMapping("/{id}/password")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "重置用户密码", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Void> resetPassword(@PathVariable Long id, @RequestParam(name = "newPassword") String newPassword) {
        User user = userMapper.selectById(id);
        if (user == null) {
            return Result.notFound("用户不存在");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        userMapper.updateById(user);
        return Result.okMsg("密码重置成功");
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "删除用户", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Void> delete(@PathVariable Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            return Result.notFound("用户不存在");
        }
        
        // 启用状态的用户不能删除
        if (user.getStatus() != null && user.getStatus() == 1) {
            return Result.error("启用状态的用户不能删除，请先禁用");
        }
        
        userMapper.deleteById(id);
        return Result.okMsg("用户删除成功");
    }

    @PutMapping("/{id}/roles")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "分配用户角色", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Void> assignRoles(@PathVariable Long id, @RequestBody Long[] roleIds) {
        // 先删除旧角色
        jdbcTemplate.update("DELETE FROM sys_user_roles WHERE user_id = ?", id);
        // 插入新角色
        for (Long roleId : roleIds) {
            jdbcTemplate.update("INSERT INTO sys_user_roles(user_id, role_id) VALUES(?, ?)", id, roleId);
        }
        return Result.okMsg("角色分配成功");
    }
}
