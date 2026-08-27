package com.gameon.repository;

import com.gameon.model.Game;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface GameRepository extends JpaRepository<Game, UUID> {
    List<Game> findByUserIdOrderByCreatedAtDesc(UUID userId);
    Optional<Game> findByIdAndUserId(UUID id, UUID userId);
}
