package com.gameon.dto;

import java.util.List;
import java.util.Map;

public class AuthDtos {

    public record GoogleUrlResponse(String url) {}

    public record ExchangeRequest(String code, Integer redirectPort) {}

    public record RefreshRequest(String refreshToken) {}

    public record GoogleTokens(String accessToken, String refreshToken, Long expiresAt) {}

    public record UserResponse(
            String id,
            String email,
            String displayName,
            String picture,
            String plan,
            Integer storageUsedMb
    ) {}

    public record ExchangeResponse(
            String accessToken,
            String refreshToken,
            Long expiresAt,
            UserResponse user,
            GoogleTokens googleTokens
    ) {}

    public record RefreshResponse(String accessToken, Long expiresAt) {}
}
