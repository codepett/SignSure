//
//  SignSureApp.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//


import SwiftUI
import FacebookCore

@main
struct SignSureApp: App {
    // Integrate AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SessionManager.shared)
        }
    }
}
