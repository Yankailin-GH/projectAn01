package com.an.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class AdminViewController {

    @GetMapping("/admin")
    public String index() {
        return "admin/index";
    }

    @GetMapping("/admin/users")
    public String users() {
        return "admin/users";
    }

    @GetMapping("/admin/roles")
    public String roles() {
        return "admin/roles";
    }

    @GetMapping("/admin/menus")
    public String menus() {
        return "admin/menus";
    }

    @GetMapping("/admin/orders")
    public String orders() {
        return "admin/orders";
    }

    @GetMapping("/profile/info")
    public String profileInfo() {
        return "user/profile";
    }

    @GetMapping("/profile/password")
    public String profilePassword() {
        return "user/password";
    }
}

