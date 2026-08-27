package com.gameon.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.time.Instant;
import java.util.List;

public class GameDtos {

    public record CreateGameRequest(
            @NotBlank String name,
            @NotBlank String slug,
            String exePath,
            @NotEmpty List<String> savePaths,
            String platform
    ) {}

    public record UpdateGameRequest(String name, List<String> savePaths) {}

    public record GameResponse(
            String id,
            String name,
            String slug,
            String exePath,
            List<String> savePaths,
            String driveFolderId,
            String platform,
            Boolean isActive,
            Instant lastSyncedAt,
            Instant createdAt
    ) {}

    public record GameListResponse(List<GameResponse> games) {}
}
