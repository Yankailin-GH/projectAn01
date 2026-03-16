package com.an.service;

import com.an.dto.request.LoginRequest;
import com.an.dto.request.RegisterRequest;
import com.an.dto.response.JwtResponse;

public interface AuthService {
    JwtResponse login(LoginRequest request);
    void register(RegisterRequest request);
    JwtResponse refreshToken(String refreshToken);
}
