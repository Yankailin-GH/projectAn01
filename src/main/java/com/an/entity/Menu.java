package com.an.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

/**
 * 菜单实体（包含菜单和按钮）
 */
@TableName("sys_menus")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Menu extends BaseEntity {

    private String name;           // 菜单名称
    private String path;           // 路由路径
    private String icon;           // 图标
    private Integer type;          // 类型：1=菜单，2=按钮
    private Long parentId;         // 父菜单ID
    private Integer sortOrder;     // 排序
    private String permission;     // 权限标识（如 user:add, user:edit）
    private String component;      // 组件路径

    @TableField(exist = false)
    @Builder.Default
    private List<Menu> children = new ArrayList<>();

    public enum MenuType {
        MENU(1, "菜单"),
        BUTTON(2, "按钮");

        public final int code;
        public final String desc;

        MenuType(int code, String desc) {
            this.code = code;
            this.desc = desc;
        }
    }
}

