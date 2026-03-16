package com.an.mapper;

import com.an.entity.Product;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface ProductMapper extends BaseMapper<Product> {

    /** 分页查询（带分类信息） */
    IPage<Product> selectProductPage(Page<Product> page,
                                      @Param("status") String status);

    /** 关键词搜索 */
    IPage<Product> searchProducts(@Param("keyword") String keyword,
                                   Page<Product> page);

    @Select("SELECT * FROM products WHERE sku = #{sku} AND deleted = 0 LIMIT 1")
    Product selectBySku(@Param("sku") String sku);

    @Select("SELECT COUNT(1) FROM products WHERE deleted = 0")
    long countActiveProducts();
}

