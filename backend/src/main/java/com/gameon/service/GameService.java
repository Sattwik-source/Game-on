package com.gameon.service;

import com.gameon.dto.GameDtos.*;
import com.gameon.model.Game;
import com.gameon.repository.GameRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class GameService {

    private final GameRepository gameRepository;

    public GameService(GameRepository gameRepository) {
        this.gameRepository = gameRepository;
    }

    public List<GameResponse> listForUser(UUID userId) {
        return gameRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public GameResponse getOne(UUID userId, UUID gameId) {
        Game game = gameRepository.findByIdAndUserId(gameId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Game not found"));
        return toResponse(game);
    }

    @Transactional
    public GameResponse create(UUID userId, CreateGameRequest req) {
        Game game = new Game();
        game.setUserId(userId);
        game.setName(req.name());
        game.setSlug(req.slug());
        game.setExePath(req.exePath());
        game.setSavePaths(req.savePaths());
        game.setPlatform(req.platform() != null ? req.platform() : "pc");

        // NOTE: Drive folder creation happens client-side (Flutter app
        // owns the Drive session) — driveFolderId is set via a follow-up
        // PUT once the app has created "GameOn/<slug>/" in the user's Drive.

        return toResponse(gameRepository.save(game));
    }

    @Transactional
    public GameResponse update(UUID userId, UUID gameId, UpdateGameRequest req) {
        Game game = gameRepository.findByIdAndUserId(gameId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Game not found"));

        if (req.name() != null) game.setName(req.name());
        if (req.savePaths() != null) game.setSavePaths(req.savePaths());

        return toResponse(gameRepository.save(game));
    }

    @Transactional
    public void delete(UUID userId, UUID gameId) {
        Game game = gameRepository.findByIdAndUserId(gameId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Game not found"));
        gameRepository.delete(game);
        // Drive files are intentionally NOT deleted here — they remain
        // in the user's own Drive even after unregistering the game.
    }

    private GameResponse toResponse(Game g) {
        return new GameResponse(
                g.getId().toString(),
                g.getName(),
                g.getSlug(),
                g.getExePath(),
                g.getSavePaths(),
                g.getDriveFolderId(),
                g.getPlatform(),
                g.getIsActive(),
                g.getLastSyncedAt(),
                g.getCreatedAt()
        );
    }
}
