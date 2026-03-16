package com.an.service.impl;

import com.an.dto.request.LoginRequest;
import com.an.dto.request.RegisterRequest;
import com.an.dto.response.JwtResponse;
import com.an.dto.response.MenuVo;
import com.an.entity.Role;
import com.an.entity.User;
import com.an.exception.BusinessException;
import com.an.mapper.RoleMapper;
import com.an.mapper.UserMapper;
import com.an.security.jwt.JwtTokenProvider;
import com.an.security.service.UserDetailsImpl;
import com.an.service.AuthService;
import com.an.service.MenuService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserMapper userMapper;
    private final RoleMapper roleMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final JdbcTemplate jdbcTemplate;
    private final MenuService menuService;

    @Override
    public JwtResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword()));
        SecurityContextHolder.getContext().setAuthentication(authentication);

        String accessToken  = jwtTokenProvider.generateAccessToken(authentication);
        String refreshToken = jwtTokenProvider.generateRefreshToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        List<String> roles = userDetails.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toList());

        // 判断是否 admin 角色
        boolean isAdmin = roles.stream().anyMatch(r -> r.equals("ROLE_ADMIN"));

        // 查询该用户的菜单权限
        List<MenuVo> menus = menuService.getMenuVoByUserId(userDetails.getId(), isAdmin);

        log.info("用户登录成功: {}, isAdmin={}, 菜单数量={}", userDetails.getUsername(), isAdmin, menus.size());
        return JwtResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(userDetails.getId())
                .username(userDetails.getUsername())
                .email(userDetails.getEmail())
                .roles(roles)
                .menus(menus)
                .build();
    }

    @Override
    @Transactional
    public void register(RegisterRequest request) {
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new BusinessException("两次密码不一致");
        }
        if (userMapper.countByUsername(request.getUsername()) > 0) {
            throw new BusinessException("用户名已存在: " + request.getUsername());
        }
        if (userMapper.countByEmail(request.getEmail()) > 0) {
            throw new BusinessException("邮箱已被注册: " + request.getEmail());
        }
        Role userRole = roleMapper.selectByName(Role.RoleName.ROLE_USER.name());
        if (userRole == null) {
            throw new BusinessException("角色不存在，请先初始化数据");
        }

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .build();
        userMapper.insert(user);

        jdbcTemplate.update(
            "INSERT IGNORE INTO user_roles(user_id, role_id) VALUES(?, ?)",
            user.getId(), userRole.getId());
        log.info("新用户注册成功: {}", request.getUsername());
    }

    @Override
    public JwtResponse refreshToken(String refreshToken) {
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new BusinessException(401, "Refresh Token 无效或已过期");
        }
        String username = jwtTokenProvider.getUsernameFromToken(refreshToken);
        String newAccessToken = jwtTokenProvider.generateTokenFromUsername(username, 86400000L);
        return JwtResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(refreshToken)
                .build();
    }
}
