package com.gameon.controller;

import com.gameon.dto.BackupDtos.*;
import com.gameon.service.BackupService;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/backups")
public class BackupController {

    private final BackupService backupService;

    public BackupController(BackupService backupService) {
        this.backupService = backupService;
    }

    @GetMapping
    public BackupListResponse list(
            @RequestParam("game_id") UUID gameId,
            @RequestParam(defaultValue = "20") int limit
    ) {
        return new BackupListResponse(backupService.listForGame(gameId, limit));
    }

    @GetMapping("/{id}")
    public BackupResponse getOne(@AuthenticationPrincipal UUID userId, @PathVariable UUID id) {
        return backupService.getOne(userId, id);
    }

    /**
     * Records a backup that the Flutter app has already uploaded
     * directly to the user's Google Drive. This endpoint never
     * receives save-file bytes — only metadata.
     */
    @PostMapping
    public BackupResponse record(
            @AuthenticationPrincipal UUID userId,
            @Valid @RequestBody CreateBackupRequest req
    ) {
        return backupService.record(userId, req);
    }

    @DeleteMapping("/{id}")
    public void delete(@AuthenticationPrincipal UUID userId, @PathVariable UUID id) {
        backupService.delete(userId, id);
    }

    @PostMapping("/{id}/label")
    public BackupResponse label(
            @AuthenticationPrincipal UUID userId,
            @PathVariable UUID id,
            @Valid @RequestBody LabelRequest req
    ) {
        return backupService.label(userId, id, req.label());
    }
}
