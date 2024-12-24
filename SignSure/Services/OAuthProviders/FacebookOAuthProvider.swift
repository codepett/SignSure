//
//  FacebookOAuthProvider.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import Foundation
import Combine
import AppAuth
import FacebookLogin
import FacebookCore
import UIKit

class FacebookOAuthProvider: OAuthProvider {
    let serviceType: OAuthServiceType = .facebook

    private let clientID = OAuthConfig.facebookClientID
    private let redirectURI = OAuthConfig.facebookRedirectURI

    private let loginManager: LoginManager
    private let urlSession: URLSession
    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    init(loginManager: LoginManager = LoginManager(), urlSession: URLSession = .shared) {
        self.loginManager = loginManager
        self.urlSession = urlSession
    }

    func signIn(presentingViewController: UIViewController) -> AnyPublisher<OAuthTokens, Error> {
        Future<OAuthTokens, Error> { [weak self] promise in
            guard let self = self else { return }

            self.loginManager.logIn(permissions: ["public_profile", "email"], from: presentingViewController) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let result = result, !result.isCancelled else {
                    promise(.failure(AuthError.cancelled))
                    return
                }

                guard let accessToken = AccessToken.current else {
                    promise(.failure(AuthError.invalidCredentials))
                    return
                }

                self.fetchUserInfo(accessToken: accessToken.tokenString, service: .facebook) { userInfoResult in
                    switch userInfoResult {
                    case .success(let user):
                        let tokens = OAuthTokens(
                            accessToken: accessToken.tokenString,
                            idToken: nil,
                            refreshToken: nil,
                            user: user
                        )
                        KeychainHelper.shared.saveToken(accessToken.tokenString, key: "facebook_access_token")
                        promise(.success(tokens))
                    case .failure(let err):
                        promise(.failure(err))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func signOut() {
        // Implement Facebook-specific sign-out logic if necessary
        KeychainHelper.shared.deleteToken(for: "facebook_access_token")
        LoginManager().logOut()
        SessionManager.shared.clearSession()
    }

    // MARK: - Fetch User Info
    private func fetchUserInfo(accessToken: String, service: OAuthServiceType, completion: @escaping (Result<User, Error>) -> Void) {
        switch service {
        case .facebook:
            fetchFacebookUserInfo(accessToken: accessToken, completion: completion)
        default:
            completion(.failure(AuthError.genericError))
        }
    }

    private func fetchFacebookUserInfo(accessToken: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Define Facebook's User Info Endpoint with desired fields
        guard let url = URL(string: "https://graph.facebook.com/me?fields=id,name,email,picture.type(large)") else {
            completion(.failure(AuthError.genericError))
            return
        }

        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField:"Authorization")

        urlSession.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(AuthError.networkError))
                return
            }
            guard let data = data else {
                completion(.failure(AuthError.genericError))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let email = json["email"] as? String,
                   let name = json["name"] as? String,
                   let id = json["id"] as? String,
                   let pictureDict = json["picture"] as? [String: Any],
                   let dataDict = pictureDict["data"] as? [String: Any],
                   let pictureURLString = dataDict["url"] as? String,
                   let pictureURL = URL(string: pictureURLString) {

                    // Split name into first and last names
                    let nameComponents = name.split(separator: " ")
                    let firstName = nameComponents.first.map(String.init) ?? ""
                    let lastName = nameComponents.dropFirst().joined(separator: " ")

                    let user = User(
                        id: id,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        profilePictureURL: pictureURL
                    )
                    completion(.success(user))
                } else {
                    completion(.failure(AuthError.invalidCredentials))
                }
            } catch {
                completion(.failure(AuthError.decodingError))
            }
        }.resume()
    }
    
    // MARK: - Handle Redirect URL
    func handleRedirectURL(_ url: URL) -> Bool {
        // Facebook typically handles redirects via FBSDK, so we might not need to handle it here.
        // If you're using AppAuth for Facebook, implement similar to Google.
        // Otherwise, return false.
        return false
    }
}
