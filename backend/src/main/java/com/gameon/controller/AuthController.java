package com.gameon.controller;

import com.gameon.dto.AuthDtos.*;
import com.gameon.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * Returns the Google consent URL, built against the loopback port
     * the Flutter desktop app is temporarily listening on.
     */
    @GetMapping("/google/url")
    public GoogleUrlResponse getConsentUrl(@RequestParam("redirect_port") int redirectPort) {
        return new GoogleUrlResponse(authService.buildConsentUrl(redirectPort));
    }

    /**
     * Exchanges the one-time OAuth code for Google tokens, upserts the
     * user, and returns our own JWT pair plus the Google Drive tokens
     * the Flutter app needs to call the Drive API directly.
     */
    @PostMapping("/google/exchange")
    public ExchangeResponse exchange(@Valid @RequestBody ExchangeRequest req) throws Exception {
        return authService.exchangeCode(req.code(), req.redirectPort());
    }

    @PostMapping("/refresh")
    public RefreshResponse refresh(@Valid @RequestBody RefreshRequest req) {
        return authService.refresh(req.refreshToken());
    }
}
