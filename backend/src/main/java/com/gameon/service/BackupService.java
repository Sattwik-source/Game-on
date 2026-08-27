package com.gameon.service;

import com.gameon.dto.BackupDtos.*;
import com.gameon.model.Backup;
import com.gameon.repository.BackupRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * Pure metadata layer — this service never touches actual save-file
 * bytes. The Flutter app compresses, encrypts, and uploads to the
 * user's own Google Drive directly; this only records what happened
 * (Drive file ID, checksum, size) so it can be listed and restored.
 */
@Service
public class BackupService {

    private final BackupRepository backupRepository;

    public BackupService(BackupRepository backupRepository) {
        this.backupRepository = backupRepository;
    }

    public List<BackupResponse> listForGame(UUID gameId, int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        return backupRepository.findByGameIdOrderByCreatedAtDesc(gameId, pageable)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public BackupResponse getOne(UUID userId, UUID backupId) {
        Backup backup = backupRepository.findByIdAndUserId(backupId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Backup not found"));
        return toResponse(backup);
    }

    @Transactional
    public BackupResponse record(UUID userId, CreateBackupRequest req) {
        Backup backup = new Backup();
        backup.setUserId(userId);
        backup.setGameId(UUID.fromString(req.gameId()));
        backup.setDriveFileId(req.driveFileId());
        backup.setFileName(req.fileName());
        backup.setFilePath(req.filePath());
        backup.setSizeBytes(req.sizeBytes());
        backup.setCompressedBytes(req.compressedBytes());
        backup.setChecksum(req.checksum());
        backup.setTriggerType(req.trigger() != null ? req.trigger() : "auto");
        backup.setStatus("uploaded");

        return toResponse(backupRepository.save(backup));
    }

    @Transactional
    public void delete(UUID userId, UUID backupId) {
        Backup backup = backupRepository.findByIdAndUserId(backupId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Backup not found"));
        backupRepository.delete(backup);
        // NOTE: the corresponding Drive file deletion is triggered by
        // the Flutter app (DriveService.deleteFile) — it owns the Drive
        // session and does this before or after calling this endpoint.
    }

    @Transactional
    public BackupResponse label(UUID userId, UUID backupId, String label) {
        Backup backup = backupRepository.findByIdAndUserId(backupId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Backup not found"));
        backup.setLabel(label);
        return toResponse(backupRepository.save(backup));
    }

    private BackupResponse toResponse(Backup b) {
        return new BackupResponse(
                b.getId().toString(),
                b.getGameId().toString(),
                b.getDriveFileId(),
                b.getDriveRevId(),
                b.getFileName(),
                b.getSizeBytes(),
                b.getCompressedBytes(),
                b.getChecksum(),
                b.getLabel(),
                b.getTriggerType(),
                b.getStatus(),
                b.getCreatedAt()
        );
    }
}
