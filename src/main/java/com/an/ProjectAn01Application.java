package com.an;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * 项目主启动类
 * 企业级全栈应用 - Spring Boot + Thymeleaf + MyBatis-Plus
 */
@SpringBootApplication
@EnableAsync
public class ProjectAn01Application {

    public static void main(String[] args) {
        SpringApplication.run(ProjectAn01Application.class, args);
    }
}

