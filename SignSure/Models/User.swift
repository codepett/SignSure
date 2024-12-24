//
//  User.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    var email: String?
    let profilePictureURL: URL?
}
