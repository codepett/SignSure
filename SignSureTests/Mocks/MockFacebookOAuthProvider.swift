//
//  MockFacebookOAuthProvider.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import Foundation
import Combine
import UIKit
import AppAuth

/// A mock implementation of the FacebookOAuthProvider for testing purposes.
/// It simulates the OAuth flow without making real network requests.
class MockFacebookOAuthProvider: OAuthProvider {
    
    let serviceType: OAuthServiceType = .facebook

    /// Simulated access to the current authorization flow.
    /// For the mock, this is always `nil` since URL handling is not required.
    var currentAuthorizationFlow: OIDExternalUserAgentSession? {
        get { return nil }
        set { /* No operation for mock */ }
    }

    /// Handles the incoming URL for the OAuth flow.
    /// Since this is a mock, it does not handle any URLs and always returns `false`.
    /// - Parameter url: The URL to handle.
    /// - Returns: `false` indicating the URL was not handled.
    func handleRedirectURL(_ url: URL) -> Bool {
        // In a real scenario, you would parse the URL and determine if it pertains to Facebook OAuth.
        // For the mock, we assume no URL handling is necessary.
        return false
    }
    
    /// Simulates the sign-in process by returning mock OAuth tokens after a short delay.
    /// - Parameter presentingViewController: The view controller presenting the sign-in UI.
    /// - Returns: A publisher emitting `OAuthTokens` or an `Error`.
    func signIn(presentingViewController: UIViewController) -> AnyPublisher<OAuthTokens, Error> {
        // Simulate network delay using a short delay.
        Just(MockFacebookOAuthProvider.mockTokens())
            .delay(for: .seconds(1), scheduler: RunLoop.main) // Simulate asynchronous behavior
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /// Simulates the sign-out process.
    /// Since this is a mock, it doesn't perform any real sign-out operations.
    func signOut() {
        // Mock sign-out logic if necessary
        // For example, resetting mock tokens or clearing user state
    }
    
    /// Generates mock OAuth tokens for testing purposes.
    /// - Returns: An instance of `OAuthTokens` with predefined mock data.
    private static func mockTokens() -> OAuthTokens {
        let user = User(
            id: "mock_facebook_id_12345",
            firstName: "Test",
            lastName: "User",
            email: "testuser@mockfacebook.com",
            profilePictureURL: URL(string: "https://example.com/mock_profile_picture.jpg")
        )
        return OAuthTokens(
            accessToken: "mock_facebook_access_token",
            idToken: "mock_facebook_id_token",
            refreshToken: "mock_facebook_refresh_token",
            user: user
        )
    }
}
