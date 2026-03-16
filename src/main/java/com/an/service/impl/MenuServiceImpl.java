package com.an.service.impl;

import com.an.dto.response.MenuTreeDto;
import com.an.dto.response.MenuVo;
import com.an.entity.Menu;
import com.an.exception.BusinessException;
import com.an.exception.ResourceNotFoundException;
import com.an.mapper.MenuMapper;
import com.an.service.MenuService;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class MenuServiceImpl implements MenuService {

    private final MenuMapper menuMapper;
    private final JdbcTemplate jdbcTemplate;

    @Override
    public IPage<Menu> findAll(int pageNum, int pageSize) {
        Page<Menu> page = new Page<>(pageNum, pageSize);
        return menuMapper.selectPage(page, null);
    }

    @Override
    public Menu findById(Long id) {
        Menu menu = menuMapper.selectById(id);
        if (menu == null) {
            throw new ResourceNotFoundException("菜单", id);
        }
        return menu;
    }

    @Override
    @Transactional
    public Menu create(Menu menu) {
        menuMapper.insert(menu);
        log.info("菜单创建成功: id={}, name={}", menu.getId(), menu.getName());
        return menu;
    }

    @Override
    @Transactional
    public Menu update(Long id, Menu menu) {
        findById(id);
        menu.setId(id);
        menuMapper.updateById(menu);
        log.info("菜单更新成功: id={}", id);
        return menu;
    }

    @Override
    @Transactional
    public void delete(Long id) {
        findById(id);

        // 检查是否有子菜单
        List<Menu> children = menuMapper.selectChildMenus(id);
        if (!children.isEmpty()) {
            throw new BusinessException("该菜单下还有 " + children.size() + " 个子菜单，无法删除");
        }

        // 检查是否有角色使用该菜单
        Integer roleCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM sys_role_menus WHERE menu_id = ?",
            Integer.class, id);
        if (roleCount != null && roleCount > 0) {
            throw new BusinessException("该菜单被 " + roleCount + " 个角色使用，无法删除");
        }

        menuMapper.deleteById(id);
        log.info("菜单删除: id={}", id);
    }

    @Override
    public List<MenuTreeDto> getMenuTree() {
        List<Menu> rootMenus = menuMapper.selectRootMenus();
        return buildMenuTree(rootMenus);
    }

    @Override
    public List<MenuTreeDto> getMenuTreeByRoleId(Long roleId) {
        List<Menu> menus = menuMapper.selectMenusByRoleId(roleId);
        return buildMenuTree(menus);
    }

    @Override
    public List<MenuVo> getMenuVoByUserId(Long userId, boolean isAdmin) {
        List<Menu> allFlat = isAdmin
                ? menuMapper.selectAllMenusFlat()
                : menuMapper.selectMenusByUserId(userId);
        return buildMenuVoTree(allFlat, null);
    }

    @Override
    public List<MenuVo> getAllMenuTree() {
        List<Menu> allFlat = menuMapper.selectAllMenusFlat();
        return buildMenuVoTree(allFlat, null);
    }

    @Override
    public List<Long> getMenuIdsByRoleId(Long roleId) {
        return menuMapper.selectMenuIdsByRoleId(roleId);
    }

    // ==================== 私有辅助方法 ====================

    private List<MenuTreeDto> buildMenuTree(List<Menu> menus) {
        return menus.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    private MenuTreeDto convertToDto(Menu menu) {
        MenuTreeDto dto = MenuTreeDto.builder()
                .id(menu.getId())
                .name(menu.getName())
                .path(menu.getPath())
                .icon(menu.getIcon())
                .type(menu.getType())
                .permission(menu.getPermission())
                .component(menu.getComponent())
                .sortOrder(menu.getSortOrder())
                .build();
        List<Menu> children = menuMapper.selectChildMenus(menu.getId());
        if (!children.isEmpty()) {
            dto.setChildren(children.stream()
                    .map(this::convertToDto)
                    .collect(Collectors.toList()));
        }
        return dto;
    }

    /**
     * 将平铺菜单列表构建成树形 MenuVo
     */
    private List<MenuVo> buildMenuVoTree(List<Menu> flat, Long parentId) {
        List<MenuVo> result = new ArrayList<>();
        for (Menu menu : flat) {
            boolean isRoot = (parentId == null && menu.getParentId() == null);
            boolean isChild = (parentId != null && parentId.equals(menu.getParentId()));
            if (isRoot || isChild) {
                MenuVo vo = toMenuVo(menu);
                List<MenuVo> children = buildMenuVoTree(flat, menu.getId());
                if (!children.isEmpty()) {
                    vo.setChildren(children);
                }
                result.add(vo);
            }
        }
        return result;
    }

    private MenuVo toMenuVo(Menu menu) {
        return MenuVo.builder()
                .id(menu.getId())
                .name(menu.getName())
                .path(menu.getPath())
                .icon(menu.getIcon())
                .type(menu.getType())
                .parentId(menu.getParentId())
                .sortOrder(menu.getSortOrder())
                .permission(menu.getPermission())
                .component(menu.getComponent())
                .build();
    }
}


