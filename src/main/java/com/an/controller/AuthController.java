package com.an.controller;

import com.an.dto.response.MenuVo;
import com.an.dto.response.Result;
import com.an.dto.response.JwtResponse;
import com.an.dto.request.LoginRequest;
import com.an.dto.request.RegisterRequest;
import com.an.security.service.UserDetailsImpl;
import com.an.service.AuthService;
import com.an.service.MenuService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 认证 REST API（供前端 AJAX / axios 调用）
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "认证接口", description = "注册、登录、刷新Token")
public class AuthController {

    private final AuthService authService;
    private final MenuService menuService;

    @PostMapping("/login")
    @Operation(summary = "用户登录")
    public Result<JwtResponse> login(@Valid @RequestBody LoginRequest request) {
        JwtResponse jwt = authService.login(request);
        return Result.ok("登录成功", jwt);
    }

    @PostMapping("/register")
    @Operation(summary = "用户注册")
    public Result<Void> register(@Valid @RequestBody RegisterRequest request) {
        authService.register(request);
        return Result.okMsg("注册成功");
    }

    @PostMapping("/refresh")
    @Operation(summary = "刷新 AccessToken")
    public Result<JwtResponse> refresh(@RequestParam String refreshToken) {
        return Result.ok(authService.refreshToken(refreshToken));
    }

    @GetMapping("/menus")
    @Operation(summary = "获取当前登录用户的菜单权限")
    public Result<List<MenuVo>> getCurrentUserMenus(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return Result.unauthorized("未登录");
        }
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        boolean isAdmin = authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .anyMatch(r -> r.equals("ROLE_ADMIN"));
        List<MenuVo> menus = menuService.getMenuVoByUserId(userDetails.getId(), isAdmin);
        return Result.ok(menus);
    }
}
