package com.an.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 统一 API 响应体 - 简化版
 * 
 * 成功响应示例：
 * {
 *   "code": 0,
 *   "msg": "操作成功",
 *   "data": {...}
 * }
 * 
 * 失败响应示例：
 * {
 *   "code": 400,
 *   "msg": "参数错误"
 * }
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Result<T> {

    /** 状态码：0=成功，其他=失败 */
    @Builder.Default
    private int code = 0;

    /** 提示信息 */
    @Builder.Default
    private String msg = "操作成功";

    /** 返回数据 */
    private T data;

    // ==================== 成功响应 ====================

    /**
     * 成功响应（无数据）
     */
    public static <T> Result<T> ok() {
        return Result.<T>builder()
                .code(0)
                .msg("操作成功")
                .build();
    }

    /**
     * 成功响应（带数据）
     */
    public static <T> Result<T> ok(T data) {
        return Result.<T>builder()
                .code(0)
                .msg("操作成功")
                .data(data)
                .build();
    }

    /**
     * 成功响应（自定义消息）
     */
    public static <T> Result<T> ok(String msg, T data) {
        return Result.<T>builder()
                .code(0)
                .msg(msg)
                .data(data)
                .build();
    }

    /**
     * 成功响应（仅消息）
     */
    public static <T> Result<T> okMsg(String msg) {
        return Result.<T>builder()
                .code(0)
                .msg(msg)
                .build();
    }

    // ==================== 失败响应 ====================

    /**
     * 失败响应（默认 400）
     */
    public static <T> Result<T> fail(String msg) {
        return Result.<T>builder()
                .code(400)
                .msg(msg)
                .build();
    }

    /**
     * 失败响应（自定义状态码）
     */
    public static <T> Result<T> fail(int code, String msg) {
        return Result.<T>builder()
                .code(code)
                .msg(msg)
                .build();
    }

    /**
     * 失败响应（带数据）
     */
    public static <T> Result<T> fail(int code, String msg, T data) {
        return Result.<T>builder()
                .code(code)
                .msg(msg)
                .data(data)
                .build();
    }

    // ==================== 常见错误码 ====================

    /** 参数错误 */
    public static <T> Result<T> paramError(String msg) {
        return fail(400, msg);
    }

    /** 未授权 */
    public static <T> Result<T> unauthorized(String msg) {
        return fail(401, msg);
    }

    /** 禁止访问 */
    public static <T> Result<T> forbidden(String msg) {
        return fail(403, msg);
    }

    /** 资源不存在 */
    public static <T> Result<T> notFound(String msg) {
        return fail(404, msg);
    }

    /** 服务器错误 */
    public static <T> Result<T> error(String msg) {
        return fail(500, msg);
    }

    // ==================== 便捷方法 ====================

    /**
     * 判断是否成功
     */
    public boolean isSuccess() {
        return code == 0;
    }

    /**
     * 判断是否失败
     */
    public boolean isFail() {
        return code != 0;
    }
}

