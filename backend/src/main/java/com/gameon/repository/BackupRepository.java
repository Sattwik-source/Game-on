package com.gameon.repository;

import com.gameon.model.Backup;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface BackupRepository extends JpaRepository<Backup, UUID> {
    Page<Backup> findByGameIdOrderByCreatedAtDesc(UUID gameId, Pageable pageable);
    Optional<Backup> findByIdAndUserId(UUID id, UUID userId);
    long countByUserId(UUID userId);
}
