package com.an.mapper;

import com.an.entity.Menu;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface MenuMapper extends BaseMapper<Menu> {

    @Select("SELECT * FROM sys_menus WHERE parent_id IS NULL AND deleted = 0 ORDER BY sort_order ASC")
    List<Menu> selectRootMenus();

    @Select("SELECT * FROM sys_menus WHERE parent_id = #{parentId} AND deleted = 0 ORDER BY sort_order ASC")
    List<Menu> selectChildMenus(Long parentId);

    @Select("SELECT * FROM sys_menus WHERE type = 1 AND deleted = 0 ORDER BY sort_order ASC")
    List<Menu> selectAllMenus();

    @Select("SELECT DISTINCT m.* FROM sys_menus m " +
            "INNER JOIN sys_role_menus rm ON m.id = rm.menu_id " +
            "WHERE rm.role_id = #{roleId} AND m.deleted = 0 " +
            "ORDER BY m.sort_order ASC")
    List<Menu> selectMenusByRoleId(Long roleId);

    @Select("SELECT DISTINCT m.* FROM sys_menus m " +
            "INNER JOIN sys_role_menus rm ON m.id = rm.menu_id " +
            "INNER JOIN sys_user_roles ur ON rm.role_id = ur.role_id " +
            "WHERE ur.user_id = #{userId} AND m.deleted = 0 " +
            "ORDER BY m.sort_order ASC")
    List<Menu> selectMenusByUserId(Long userId);

    @Select("SELECT * FROM sys_menus WHERE deleted = 0 ORDER BY sort_order ASC")
    List<Menu> selectAllMenusFlat();

    @Select("SELECT DISTINCT rm.menu_id FROM sys_role_menus rm WHERE rm.role_id = #{roleId}")
    List<Long> selectMenuIdsByRoleId(Long roleId);
}

