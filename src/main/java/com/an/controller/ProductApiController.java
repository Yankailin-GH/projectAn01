package com.an.controller;

import com.an.dto.response.Result;
import com.an.dto.response.PageResult;
import com.an.entity.Product;
import com.an.service.ProductService;
import com.an.dto.request.ProductRequest;
import com.baomidou.mybatisplus.core.metadata.IPage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
@Tag(name = "商品接口", description = "商品 CRUD")
public class ProductApiController {

    private final ProductService productService;

    @GetMapping
    @Operation(summary = "分页获取商品列表")
    public Result<PageResult<Product>> list(
            @RequestParam(name = "page", defaultValue = "1")  int page,
            @RequestParam(name = "size", defaultValue = "12") int size,
            @RequestParam(name = "keyword", required = false) String keyword) {

        IPage<Product> pageData = (keyword != null && !keyword.isBlank())
                ? productService.search(keyword, page, size)
                : productService.findAll(page, size);

        PageResult<Product> pageResult = PageResult.<Product>builder()
                .current(pageData.getCurrent())
                .size(pageData.getSize())
                .total(pageData.getTotal())
                .pages(pageData.getPages())
                .records(pageData.getRecords())
                .build();

        return Result.ok(pageResult);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID获取商品")
    public Result<Product> getById(@PathVariable Long id) {
        return Result.ok(productService.findById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "创建商品", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Product> create(@Valid @RequestBody ProductRequest request) {
        return Result.ok("商品创建成功", productService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "更新商品", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Product> update(@PathVariable Long id,
                                  @Valid @RequestBody ProductRequest request) {
        return Result.ok("更新成功", productService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "删除商品", security = @SecurityRequirement(name = "bearerAuth"))
    public Result<Void> delete(@PathVariable Long id) {
        productService.delete(id);
        return Result.okMsg("删除成功");
    }
}
