package com.an.service;

import com.an.dto.response.MenuTreeDto;
import com.an.dto.response.MenuVo;
import com.an.entity.Menu;
import com.baomidou.mybatisplus.core.metadata.IPage;

import java.util.List;

public interface MenuService {
    IPage<Menu> findAll(int pageNum, int pageSize);
    Menu findById(Long id);
    Menu create(Menu menu);
    Menu update(Long id, Menu menu);
    void delete(Long id);
    List<MenuTreeDto> getMenuTree();
    List<MenuTreeDto> getMenuTreeByRoleId(Long roleId);
    /** 根据用户ID获取菜单树（admin 返回全部） */
    List<MenuVo> getMenuVoByUserId(Long userId, boolean isAdmin);
    /** 获取全部菜单的树形 VO（供角色分配使用） */
    List<MenuVo> getAllMenuTree();
    /** 获取角色已分配的菜单ID列表 */
    List<Long> getMenuIdsByRoleId(Long roleId);
}

