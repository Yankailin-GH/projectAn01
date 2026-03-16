package com.an.config;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

/**
 * MyBatis-Plus 自动填充处理器（替代 JPA @CreatedDate / @CreatedBy）
 */
@Slf4j
@Component
public class MyBatisMetaObjectHandler implements MetaObjectHandler {

    @Override
    public void insertFill(MetaObject metaObject) {
        LocalDate today = LocalDate.now();
        String operator = getCurrentUser();
        this.strictInsertFill(metaObject, "createdAt",  LocalDate.class, today);
        this.strictInsertFill(metaObject, "updatedAt",  LocalDate.class, today);
        this.strictInsertFill(metaObject, "createdBy",  String.class, operator);
        this.strictInsertFill(metaObject, "updatedBy",  String.class, operator);
        this.strictInsertFill(metaObject, "deleted",    Integer.class, 0);
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updatedAt", LocalDate.class, LocalDate.now());
        this.strictUpdateFill(metaObject, "updatedBy", String.class, getCurrentUser());
    }

    private String getCurrentUser() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.isAuthenticated()
                    && !"anonymousUser".equals(auth.getName())) {
                return auth.getName();
            }
        } catch (Exception ignored) {}
        return "system";
    }
}

