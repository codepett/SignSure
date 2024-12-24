//
//  SignInOptionsViewModel.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import SwiftUI
import Combine
import UIKit

class SignInOptionsViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var authError: AuthError?

    private var cancellables = Set<AnyCancellable>()
    private let authenticationUseCase: AuthenticationUseCase
    weak var presentingViewController: UIViewController?

    init(authenticationUseCase: AuthenticationUseCase = AuthenticationUseCase()) {
        self.authenticationUseCase = authenticationUseCase
    }

    func signIn(with serviceType: OAuthServiceType) {
        guard let viewController = presentingViewController else {
            self.authError = AuthError.noPresentingViewController
            return
        }

        // Prevent setting a new error if one is already being presented
        guard authError == nil else { return }

        isLoading = true
        authError = nil
        authenticationUseCase.signIn(with: serviceType, presentingViewController: viewController)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    print("\(serviceType) Sign-In Error: \(error.localizedDescription)")
                    self.authError = AuthError.oauthFailed(error.localizedDescription)
                }
            }, receiveValue: { user in
                SessionManager.shared.setUser(user)
                self.user = user
            })
            .store(in: &cancellables)
    }

    func signOut(from serviceType: OAuthServiceType) {
        authenticationUseCase.signOut(from: serviceType)
        // Optionally, clear user data
        if serviceType == .google || serviceType == .facebook {
            SessionManager.shared.clearSession()
        }
    }
}
