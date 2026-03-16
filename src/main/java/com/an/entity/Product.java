package com.an.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

import java.math.BigDecimal;

@TableName("products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product extends BaseEntity {

    private String name;

    private String description;

    private BigDecimal price;

    @Builder.Default
    private Integer stock = 0;

    private String imageUrl;

    private String sku;

    @Builder.Default
    private String status = ProductStatus.ACTIVE.name();

    private Long categoryId;

    /** 非数据库字段 - 关联查询时填充 */
    @TableField(exist = false)
    private Category category;

    public enum ProductStatus {
        ACTIVE, INACTIVE, OUT_OF_STOCK
    }
}
