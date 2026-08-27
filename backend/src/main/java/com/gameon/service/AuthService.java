package com.gameon.service;

import com.gameon.dto.AuthDtos.*;
import com.gameon.model.User;
import com.gameon.repository.UserRepository;
import com.gameon.security.JwtService;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeTokenRequest;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.oauth2.Oauth2;
import com.google.api.services.oauth2.model.Userinfo;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.GeneralSecurityException;
import java.io.IOException;

/**
 * Owns the full "desktop loopback" OAuth exchange: given the one-time
 * code the Flutter app captured from its temporary localhost server,
 * this trades it with Google for tokens, fetches the user's profile,
 * upserts the local {@link User} row, and issues our own JWT pair.
 */
@Service
public class AuthService {

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final GoogleAuthorizationCodeFlow googleFlow;
    private final EncryptionService encryptionService;

    @Value("${gameon.google.client-id}")
    private String clientId;

    @Value("${gameon.google.client-secret}")
    private String clientSecret;

    public AuthService(
            UserRepository userRepository,
            JwtService jwtService,
            GoogleAuthorizationCodeFlow googleFlow,
            EncryptionService encryptionService
    ) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.googleFlow = googleFlow;
        this.encryptionService = encryptionService;
    }

    /**
     * Builds the redirect_uri dynamically against the loopback port the
     * Flutter app is temporarily listening on, per RFC 8252 (OAuth for
     * native apps).
     */
    public String buildConsentUrl(int redirectPort) {
        String redirectUri = "http://127.0.0.1:" + redirectPort;
        return googleFlow.newAuthorizationUrl()
                .setRedirectUri(redirectUri)
                .set("prompt", "consent")
                .build();
    }

    @Transactional
    public ExchangeResponse exchangeCode(String code, int redirectPort)
            throws GeneralSecurityException, IOException {

        String redirectUri = "http://127.0.0.1:" + redirectPort;

        GoogleTokenResponse tokenResponse = new GoogleAuthorizationCodeTokenRequest(
                GoogleNetHttpTransport.newTrustedTransport(),
                GsonFactory.getDefaultInstance(),
                clientId,
                clientSecret,
                code,
                redirectUri
        ).execute();

        Oauth2 oauth2 = new Oauth2.Builder(
                GoogleNetHttpTransport.newTrustedTransport(),
                GsonFactory.getDefaultInstance(),
                tokenResponse.getAccessToken() == null
                        ? null
                        : request -> request.getHeaders().setAuthorization("Bearer " + tokenResponse.getAccessToken())
        ).build();

        Userinfo profile = oauth2.userinfo().get().execute();

        User user = userRepository.findByGoogleSub(profile.getId())
                .orElseGet(User::new);

        user.setGoogleSub(profile.getId());
        user.setEmail(profile.getEmail());
        user.setDisplayName(profile.getName());
        user.setPictureUrl(profile.getPicture());
        user.setGoogleAccessToken(encryptionService.encrypt(tokenResponse.getAccessToken()));
        if (tokenResponse.getRefreshToken() != null) {
            user.setGoogleRefreshToken(encryptionService.encrypt(tokenResponse.getRefreshToken()));
        }

        user = userRepository.save(user);

        String accessToken = jwtService.generateAccessToken(user.getId(), user.getEmail());
        String refreshToken = jwtService.generateRefreshToken(user.getId());

        return new ExchangeResponse(
                accessToken,
                refreshToken,
                System.currentTimeMillis() + jwtService.accessTokenExpiryMillis(),
                new UserResponse(
                        user.getId().toString(),
                        user.getEmail(),
                        user.getDisplayName(),
                        user.getPictureUrl(),
                        user.getPlan(),
                        user.getStorageUsedMb()
                ),
                new GoogleTokens(
                        tokenResponse.getAccessToken(),
                        tokenResponse.getRefreshToken(),
                        System.currentTimeMillis() + (tokenResponse.getExpiresInSeconds() * 1000)
                )
        );
    }

    public RefreshResponse refresh(String refreshToken) {
        if (!jwtService.isValid(refreshToken) || !jwtService.isRefreshToken(refreshToken)) {
            throw new IllegalArgumentException("Invalid refresh token");
        }
        var userId = jwtService.extractUserId(refreshToken);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        String newAccessToken = jwtService.generateAccessToken(user.getId(), user.getEmail());
        return new RefreshResponse(
                newAccessToken,
                System.currentTimeMillis() + jwtService.accessTokenExpiryMillis()
        );
    }
}
