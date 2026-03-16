package com.an.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

/**
 * 角色实体
 */
@TableName("sys_roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Role extends BaseEntity {

    private String name;           // 角色名称
    private String code;           // 角色编码
    private String description;    // 角色描述
    private Integer status;        // 状态：0=禁用，1=启用

    /**
     * 角色名称枚举
     */
    public enum RoleName {
        ROLE_ADMIN("管理员"),
        ROLE_USER("普通用户"),
        ROLE_MODERATOR("内容审核员");

        public final String desc;

        RoleName(String desc) {
            this.desc = desc;
        }
    }
}
