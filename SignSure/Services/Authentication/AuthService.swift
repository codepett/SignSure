//
//  AuthService.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import Combine
import UIKit

class AuthService {
    private let oauthService: OAuthService

    init(oauthService: OAuthService = .shared) {
        self.oauthService = oauthService
    }

    func signIn(with serviceType: OAuthServiceType, presentingViewController: UIViewController) -> AnyPublisher<User, AuthError> {
        oauthService.signIn(service: serviceType, presentingViewController: presentingViewController)
            .tryMap { tokens -> User in
                guard let user = tokens.user else {
                    throw AuthError.invalidCredentials
                }
                return user
            }
            .mapError { error in
                return error as? AuthError ?? .genericError
            }
            .eraseToAnyPublisher()
    }

    func signOut(from serviceType: OAuthServiceType) {
        oauthService.signOut(service: serviceType)
    }
}
