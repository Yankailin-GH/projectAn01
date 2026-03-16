package com.an.service.impl;

import com.an.dto.request.ProductRequest;
import com.an.entity.Category;
import com.an.entity.Product;
import com.an.exception.ResourceNotFoundException;
import com.an.mapper.CategoryMapper;
import com.an.mapper.ProductMapper;
import com.an.service.ProductService;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductMapper productMapper;
    private final CategoryMapper categoryMapper;

    @Override
    public IPage<Product> findAll(int pageNum, int pageSize) {
        Page<Product> page = new Page<>(pageNum, pageSize);
        return productMapper.selectProductPage(page, Product.ProductStatus.ACTIVE.name());
    }

    @Override
    public IPage<Product> search(String keyword, int pageNum, int pageSize) {
        Page<Product> page = new Page<>(pageNum, pageSize);
        return productMapper.searchProducts(keyword, page);
    }

    @Override
    public Product findById(Long id) {
        Product product = productMapper.selectById(id);
        if (product == null) {
            throw new ResourceNotFoundException("商品", id);
        }
        return product;
    }

    @Override
    @Transactional
    public Product create(ProductRequest request) {
        Product product = Product.builder()
                .name(request.getName())
                .description(request.getDescription())
                .price(request.getPrice())
                .stock(request.getStock())
                .imageUrl(request.getImageUrl())
                .sku(request.getSku())
                .categoryId(request.getCategoryId())
                .build();
        productMapper.insert(product);
        log.info("商品创建成功: id={}, name={}", product.getId(), product.getName());
        return product;
    }

    @Override
    @Transactional
    public Product update(Long id, ProductRequest request) {
        Product product = findById(id);
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setStock(request.getStock());
        product.setImageUrl(request.getImageUrl());
        product.setSku(request.getSku());
        product.setCategoryId(request.getCategoryId());
        productMapper.updateById(product);
        return product;
    }

    @Override
    @Transactional
    public void delete(Long id) {
        findById(id);
        productMapper.deleteById(id); // MyBatis-Plus 逻辑删除自动处理
        log.info("商品软删除: id={}", id);
    }

    @Override
    public long count() {
        return productMapper.countActiveProducts();
    }
}
