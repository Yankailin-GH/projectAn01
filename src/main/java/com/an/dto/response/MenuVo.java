package com.an.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 菜单视图对象（用于前端渲染权限菜单）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenuVo {
    private Long id;
    private String name;
    private String path;
    private String icon;
    private Integer type;        // 1=菜单, 2=按钮
    private Long parentId;
    private Integer sortOrder;
    private String permission;   // 权限标识
    private String component;
    private List<MenuVo> children;
}

