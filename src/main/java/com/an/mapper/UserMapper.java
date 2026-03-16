package com.an.mapper;

import com.an.entity.User;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    @Select("SELECT * FROM sys_users WHERE username LIKE CONCAT('%', #{keyword}, '%') OR email LIKE CONCAT('%', #{keyword}, '%')")
    IPage<User> searchUsers(String keyword, Page<User> page);

    @Select("SELECT COUNT(*) FROM sys_users WHERE username = #{username} AND deleted = 0")
    long countByUsername(String username);

    @Select("SELECT COUNT(*) FROM sys_users WHERE email = #{email} AND deleted = 0")
    long countByEmail(String email);

    @Select("SELECT * FROM sys_users WHERE username = #{username} AND deleted = 0 LIMIT 1")
    User selectByUsername(String username);

    /**
     * 根据用户名查询用户及其角色
     */
    @Select("SELECT * FROM sys_users WHERE username = #{username} AND deleted = 0 LIMIT 1")
    User selectByUsernameWithRoles(String username);
}
