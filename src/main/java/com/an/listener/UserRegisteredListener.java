package com.an.listener;

import com.an.event.UserRegisteredEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

/**
 * 用户注册事件监听器（可扩展发送邮件/消息队列）
 */
@Slf4j
@Component
public class UserRegisteredListener {

    @Async
    @EventListener
    public void handleUserRegistered(UserRegisteredEvent event) {
        log.info("[事件] 新用户注册: username={}, email={}",
                event.getUser().getUsername(), event.getUser().getEmail());
        // TODO: 发送欢迎邮件 / Kafka 消息
    }
}

