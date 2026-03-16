package com.an.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@TableName("categories")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Category extends BaseEntity {

    private String name;

    private String description;

    @Builder.Default
    private Integer sortOrder = 0;

    private Long parentId;

    /** 非数据库字段 */
    @TableField(exist = false)
    @Builder.Default
    private List<Category> children = new ArrayList<>();

    @TableField(exist = false)
    @Builder.Default
    private List<Product> products = new ArrayList<>();
}
