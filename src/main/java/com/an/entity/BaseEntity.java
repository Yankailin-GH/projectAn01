package com.an.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

/**
 * 基础实体类 - 自动填充审计字段
 */
@Getter
@Setter
public abstract class BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField(fill = FieldFill.INSERT)
    private LocalDate createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDate updatedAt;

    @TableField(fill = FieldFill.INSERT)
    private String createdBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private String updatedBy;

    /** 逻辑删除：0=正常，1=已删除 */
    @TableLogic
    private Integer deleted;
}
