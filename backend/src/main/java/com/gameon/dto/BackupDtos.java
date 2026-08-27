package com.gameon.dto;

import jakarta.validation.constraints.NotBlank;

import java.time.Instant;
import java.util.List;

public class BackupDtos {

    public record CreateBackupRequest(
            @NotBlank String gameId,
            @NotBlank String driveFileId,
            @NotBlank String fileName,
            @NotBlank String filePath,
            Long sizeBytes,
            Long compressedBytes,
            String checksum,
            String trigger
    ) {}

    public record LabelRequest(@NotBlank String label) {}

    public record BackupResponse(
            String id,
            String gameId,
            String driveFileId,
            String driveRevId,
            String fileName,
            Long sizeBytes,
            Long compressedBytes,
            String checksum,
            String label,
            String trigger,
            String status,
            Instant createdAt
    ) {}

    public record BackupListResponse(List<BackupResponse> backups) {}
}
