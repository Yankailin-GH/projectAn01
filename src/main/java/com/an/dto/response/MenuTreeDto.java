package com.an.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * 菜单树形结构 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MenuTreeDto {
    private Long id;
    private String name;
    private String path;
    private String icon;
    private Integer type;
    private String permission;
    private String component;
    private Integer sortOrder;

    @Builder.Default
    private List<MenuTreeDto> children = new ArrayList<>();
}

