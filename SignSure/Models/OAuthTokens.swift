//
//  OAuthTokens.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import Foundation

struct OAuthTokens {
    let accessToken: String
    let idToken: String?
    let refreshToken: String?
    let user: User?
}
