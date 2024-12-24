//
//  AuthenticationUseCase.swift
//  SignSure
//
//  Created by Petrit Vosha on 24.12.2024.
//

import Combine
import UIKit

class AuthenticationUseCase {
    private let authService: AuthService

    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }

    func signIn(with serviceType: OAuthServiceType, presentingViewController: UIViewController) -> AnyPublisher<User, AuthError> {
        authService.signIn(with: serviceType, presentingViewController: presentingViewController)
    }

    func signOut(from serviceType: OAuthServiceType) {
        authService.signOut(from: serviceType)
    }
}
