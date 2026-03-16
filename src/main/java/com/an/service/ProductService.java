package com.an.service;

import com.an.dto.request.ProductRequest;
import com.an.entity.Product;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

public interface ProductService {
    IPage<Product> findAll(int pageNum, int pageSize);
    IPage<Product> search(String keyword, int pageNum, int pageSize);
    Product findById(Long id);
    Product create(ProductRequest request);
    Product update(Long id, ProductRequest request);
    void delete(Long id);
    long count();
}
