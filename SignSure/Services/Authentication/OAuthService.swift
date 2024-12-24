//
//  OAuthService.swift
//  SignSure
//
//  Created by Petrit Vosha on 13.12.2024.
//

import Foundation
import Combine
import UIKit

class OAuthService: ObservableObject {
    static let shared = OAuthService() // Singleton for easy access

    private let googleProvider: OAuthProvider
    private let facebookProvider: OAuthProvider

    init(
        googleProvider: OAuthProvider = GoogleOAuthProvider(),
        facebookProvider: OAuthProvider = FacebookOAuthProvider()
    ) {
        self.googleProvider = googleProvider
        self.facebookProvider = facebookProvider
    }

    func signIn(service: OAuthServiceType, presentingViewController: UIViewController?) -> AnyPublisher<OAuthTokens, Error> {
        guard let presentingVC = presentingViewController else {
            return Fail(error: AuthError.noPresentingViewController)
                .eraseToAnyPublisher()
        }
        
        switch service {
        case .google:
            return googleProvider.signIn(presentingViewController: presentingVC)
        case .facebook:
            return facebookProvider.signIn(presentingViewController: presentingVC)
        }
    }

    func signOut(service: OAuthServiceType) {
        switch service {
        case .google:
            googleProvider.signOut()
        case .facebook:
            facebookProvider.signOut()
        }
    }
    
    /// Handles incoming URLs by delegating to each OAuth provider.
    func handleIncomingURL(_ url: URL) -> Bool {
        // Attempt to let each provider handle the URL.
        if googleProvider.handleRedirectURL(url) {
            return true
        }
        
        if facebookProvider.handleRedirectURL(url) {
            return true
        }
        
        // If no provider could handle the URL
        return false
    }
}
