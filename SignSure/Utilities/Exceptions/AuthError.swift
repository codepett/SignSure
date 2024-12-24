//
//  AuthError.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import Foundation

enum AuthError: Error, LocalizedError, Identifiable {
    // AuthenticationError Cases
    case noPresentingViewController
    case unknown
    case oauthFailed(String)
    
    // AuthError Cases
    case genericError
    case invalidCredentials
    case networkError
    case decodingError
    case cancelled
    case discoverConfigurationFailed
    
    // Identifiable Conformance
    var id: UUID {
        return UUID()
    }
    
    // Localized Error Descriptions
    var errorDescription: String? {
        switch self {
        case .noPresentingViewController:
            return "Unable to find presenting view controller."
        case .unknown:
            return "An unknown error occurred during authentication."
        case .oauthFailed(let message):
            return message
        case .genericError:
            return "An unknown error occurred."
        case .invalidCredentials:
            return "Invalid credentials provided."
        case .networkError:
            return "Network error. Please try again."
        case .decodingError:
            return "Failed to decode the response."
        case .cancelled:
            return "Authentication was cancelled."
        case .discoverConfigurationFailed:
            return "Failed to discover OAuth configuration."
        }
    }
}
