//
//  GoogleOAuthProvider.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import Foundation
import Combine
import AppAuth
import UIKit

class GoogleOAuthProvider: OAuthProvider {
    let serviceType: OAuthServiceType = .google

    private let clientID = OAuthConfig.googleClientID
    private let redirectURI = OAuthConfig.googleRedirectURI
    private let configuration = OIDServiceConfiguration(
        authorizationEndpoint: URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!,
        tokenEndpoint: URL(string: "https://www.googleapis.com/oauth2/v4/token")!
    )
    
    private let urlSession: URLSession
    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func signIn(presentingViewController: UIViewController) -> AnyPublisher<OAuthTokens, Error> {
        Future<OAuthTokens, Error> { [weak self] promise in
            guard let self = self else { return }

            let request = OIDAuthorizationRequest(
                configuration: self.configuration,
                clientId: self.clientID,
                scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail],
                redirectURL: URL(string: self.redirectURI)!,
                responseType: OIDResponseTypeCode,
                additionalParameters: nil
            )

            self.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { authState, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let authState = authState,
                      let accessToken = authState.lastTokenResponse?.accessToken,
                      let idToken = authState.lastTokenResponse?.idToken else {
                    promise(.failure(AuthError.invalidCredentials))
                    return
                }

                self.fetchUserInfo(accessToken: accessToken, service: .google) { userInfoResult in
                    switch userInfoResult {
                    case .success(let user):
                        let tokens = OAuthTokens(
                            accessToken: accessToken,
                            idToken: idToken,
                            refreshToken: authState.lastTokenResponse?.refreshToken,
                            user: user
                        )
                        KeychainHelper.shared.saveToken(accessToken, key: "google_access_token")
                        KeychainHelper.shared.saveToken(idToken, key: "google_id_token")
                        if let rt = tokens.refreshToken {
                            KeychainHelper.shared.saveToken(rt, key: "google_refresh_token")
                        }
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
        // Implement Google-specific sign-out logic if necessary
        KeychainHelper.shared.deleteToken(for: "google_access_token")
        KeychainHelper.shared.deleteToken(for: "google_id_token")
        KeychainHelper.shared.deleteToken(for: "google_refresh_token")
        SessionManager.shared.clearSession()
    }

    // MARK: - Fetch User Info
    private func fetchUserInfo(accessToken: String, service: OAuthServiceType, completion: @escaping (Result<User, Error>) -> Void) {
        switch service {
        case .google:
            fetchGoogleUserInfo(accessToken: accessToken, completion: completion)
        default:
            completion(.failure(AuthError.genericError))
        }
    }

    private func fetchGoogleUserInfo(accessToken: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "https://www.googleapis.com/oauth2/v2/userinfo") else {
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
                   let firstName = json["given_name"] as? String,
                   let lastName = json["family_name"] as? String,
                   let picture = json["picture"] as? String,
                   let pictureURL = URL(string: picture),
                   let id = json["id"] as? String {

                    let user = User(id: id,
                                    firstName: firstName,
                                    lastName: lastName,
                                    email: email,
                                    profilePictureURL: pictureURL)
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
        if currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url) == true {
            currentAuthorizationFlow = nil
            return true
        }
        return false
    }
}
