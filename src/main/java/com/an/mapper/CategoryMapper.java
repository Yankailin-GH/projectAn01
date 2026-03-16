package com.an.mapper;

import com.an.entity.Category;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface CategoryMapper extends BaseMapper<Category> {

    @Select("SELECT * FROM categories WHERE parent_id IS NULL AND deleted = 0 ORDER BY sort_order ASC")
    List<Category> selectRootCategories();
}

