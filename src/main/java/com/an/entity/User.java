package com.an.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@TableName("sys_users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends BaseEntity {

    private String username;

    private String email;

    private String password;

    private String fullName;

    private String phone;

    private String avatarUrl;

    @Builder.Default
    private Boolean enabled = true;

    @Builder.Default
    private Boolean accountNonLocked = true;

    private Integer status;  // 0=禁用，1=启用

    /** 非数据库字段 - 关联查询时填充 */
    @TableField(exist = false)
    @Builder.Default
    private Set<Role> roles = new HashSet<>();
}
