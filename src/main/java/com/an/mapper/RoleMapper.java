package com.an.mapper;

import com.an.entity.Role;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface RoleMapper extends BaseMapper<Role> {

    @Select("SELECT COUNT(*) FROM sys_roles WHERE name = #{name} AND deleted = 0")
    long countByName(String name);

    @Select("SELECT * FROM sys_roles WHERE name = #{name} AND deleted = 0 LIMIT 1")
    Role selectByName(String name);

    @Select("SELECT COUNT(*) FROM sys_roles WHERE code = #{code} AND deleted = 0")
    long countByCode(String code);

    @Select("SELECT * FROM sys_roles WHERE code = #{code} AND deleted = 0 LIMIT 1")
    Role selectByCode(String code);

    /**
     * 根据用户ID查询用户的所有角色
     */
    @Select("SELECT r.* FROM sys_roles r " +
            "INNER JOIN sys_user_roles ur ON r.id = ur.role_id " +
            "WHERE ur.user_id = #{userId} AND r.deleted = 0")
    List<Role> selectRolesByUserId(Long userId);
}
