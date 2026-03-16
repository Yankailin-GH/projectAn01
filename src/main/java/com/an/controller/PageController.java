package com.an.controller;

import com.an.service.ProductService;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.an.entity.Product;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
public class PageController {

    private final ProductService productService;

    @GetMapping("/")
    public String home(Model model) {
        IPage<Product> page = productService.findAll(1, 8);
        model.addAttribute("featuredProducts", page.getRecords());
        model.addAttribute("totalProducts", productService.count());
        return "home";
    }

    @GetMapping("/products")
    public String products(
            @RequestParam(name = "page", defaultValue = "1")  int page,
            @RequestParam(name = "size", defaultValue = "12") int size,
            @RequestParam(name = "keyword", required = false) String keyword,
            Model model) {

        IPage<Product> productPage = (keyword != null && !keyword.isBlank())
                ? productService.search(keyword, page, size)
                : productService.findAll(page, size);

        model.addAttribute("productPage", productPage);
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentPage", page);
        return "product/list";
    }

    @GetMapping("/products/{id}")
    public String productDetail(@PathVariable Long id, Model model) {
        model.addAttribute("product", productService.findById(id));
        return "product/detail";
    }

    @GetMapping("/auth/login")
    public String login() { return "auth/login"; }

    @GetMapping("/auth/register")
    public String register() { return "auth/register"; }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("totalProducts", productService.count());
        return "dashboard";
    }

    @GetMapping("/admin/products")
    public String adminProducts(
            @RequestParam(name = "page", defaultValue = "1")  int page,
            @RequestParam(name = "size", defaultValue = "15") int size,
            Model model) {
        model.addAttribute("productPage", productService.findAll(page, size));
        return "admin/products";
    }
}
