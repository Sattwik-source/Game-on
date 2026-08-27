package com.gameon.controller;

import com.gameon.dto.GameDtos.*;
import com.gameon.service.GameService;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/games")
public class GameController {

    private final GameService gameService;

    public GameController(GameService gameService) {
        this.gameService = gameService;
    }

    @GetMapping
    public GameListResponse list(@AuthenticationPrincipal UUID userId) {
        return new GameListResponse(gameService.listForUser(userId));
    }

    @GetMapping("/{id}")
    public GameResponse getOne(@AuthenticationPrincipal UUID userId, @PathVariable UUID id) {
        return gameService.getOne(userId, id);
    }

    @PostMapping
    public GameResponse create(
            @AuthenticationPrincipal UUID userId,
            @Valid @RequestBody CreateGameRequest req
    ) {
        return gameService.create(userId, req);
    }

    @PutMapping("/{id}")
    public GameResponse update(
            @AuthenticationPrincipal UUID userId,
            @PathVariable UUID id,
            @RequestBody UpdateGameRequest req
    ) {
        return gameService.update(userId, id, req);
    }

    @DeleteMapping("/{id}")
    public void delete(@AuthenticationPrincipal UUID userId, @PathVariable UUID id) {
        gameService.delete(userId, id);
    }
}
