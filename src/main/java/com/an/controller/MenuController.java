package com.an.controller;

import com.an.dto.response.MenuTreeDto;
import com.an.dto.response.MenuVo;
import com.an.dto.response.PageResult;
import com.an.dto.response.Result;
import com.an.entity.Menu;
import com.an.service.MenuService;
import com.baomidou.mybatisplus.core.metadata.IPage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/menus")
@RequiredArgsConstructor
@Tag(name = "菜单管理", description = "菜单和按钮管理")
public class MenuController {

    private final MenuService menuService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "分页获取菜单列表", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<PageResult<Menu>> list(
            @RequestParam(name = "page", defaultValue = "1") int page,
            @RequestParam(name = "size", defaultValue = "20") int size) {
        IPage<Menu> pageData = menuService.findAll(page, size);
        PageResult<Menu> pageResult = PageResult.<Menu>builder()
                .current(pageData.getCurrent())
                .size(pageData.getSize())
                .total(pageData.getTotal())
                .pages(pageData.getPages())
                .records(pageData.getRecords())
                .build();
        return Result.ok(pageResult);
    }

    @GetMapping("/tree")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "获取菜单树形结构", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<List<MenuTreeDto>> getMenuTree() {
        return Result.ok(menuService.getMenuTree());
    }

    @GetMapping("/tree/all")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "获取全部菜单树（含按钮，用于角色分配）", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<List<MenuVo>> getAllMenuTree() {
        return Result.ok(menuService.getAllMenuTree());
    }

    @GetMapping("/role/{roleId}/ids")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "获取角色已分配的菜单ID列表", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<List<Long>> getMenuIdsByRoleId(@PathVariable Long roleId) {
        return Result.ok(menuService.getMenuIdsByRoleId(roleId));
    }

    @GetMapping("/tree/{roleId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "根据角色获取菜单树", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<List<MenuTreeDto>> getMenuTreeByRole(@PathVariable Long roleId) {
        return Result.ok(menuService.getMenuTreeByRoleId(roleId));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "获取菜单详情", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Menu> getById(@PathVariable Long id) {
        return Result.ok(menuService.findById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "创建菜单", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Menu> create(@Valid @RequestBody Menu menu) {
        return Result.ok("菜单创建成功", menuService.create(menu));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "更新菜单", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Menu> update(@PathVariable Long id, @Valid @RequestBody Menu menu) {
        return Result.ok("菜单更新成功", menuService.update(id, menu));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "删除菜单", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Void> delete(@PathVariable Long id) {
        menuService.delete(id);
        return Result.okMsg("菜单删除成功");
    }
}
