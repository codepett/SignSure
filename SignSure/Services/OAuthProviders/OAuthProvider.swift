//
//  OAuthProvider.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import Combine
import UIKit

enum OAuthServiceType {
    case google
    case facebook
}

protocol OAuthProvider {
    var serviceType: OAuthServiceType { get }
    func signIn(presentingViewController: UIViewController) -> AnyPublisher<OAuthTokens, Error>
    func signOut()
    func handleRedirectURL(_ url: URL) -> Bool
}
