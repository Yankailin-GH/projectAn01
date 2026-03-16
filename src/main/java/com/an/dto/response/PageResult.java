package com.an.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 分页响应数据
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PageResult<T> {

    /** 当前页码 */
    private long current;

    /** 每页大小 */
    private long size;

    /** 总记录数 */
    private long total;

    /** 总页数 */
    private long pages;

    /** 数据列表 */
    private java.util.List<T> records;

    /** 是否有下一页 */
    public boolean hasNext() {
        return current < pages;
    }

    /** 是否有上一页 */
    public boolean hasPrev() {
        return current > 1;
    }
}

