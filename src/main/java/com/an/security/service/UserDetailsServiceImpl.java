package com.an.security.service;

import com.an.entity.Role;
import com.an.entity.User;
import com.an.mapper.RoleMapper;
import com.an.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 用户认证服务（MyBatis-Plus 版）
 */
@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserMapper userMapper;
    private final RoleMapper roleMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 使用 XML 中定义的带角色联查
        User user = userMapper.selectByUsernameWithRoles(username);
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在: " + username);
        }
        
        // 检查用户状态
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new UsernameNotFoundException("用户已被禁用: " + username);
        }
        
        // 若联查角色为空则单独查一次
        if (user.getRoles() == null || user.getRoles().isEmpty()) {
            List<Role> roles = roleMapper.selectRolesByUserId(user.getId());
            user.setRoles(new HashSet<>(roles));
        }
        return UserDetailsImpl.build(user);
    }
}
