//
//  SessionManager.swift
//  SignSure
//
//  Created by Petrit Vosha on 13.12.2024.
//


import Foundation
import Combine

class SessionManager: ObservableObject {
    static let shared = SessionManager()

    @Published var currentUser: User?

    private init() {}
    
    func setUser(_ user: User) {
        currentUser = user
    }
    
    func clearSession() {
        currentUser = nil
    }
}
