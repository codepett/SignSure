//
//  ContentView.swift
//  SignSure
//
//  Created by Petrit Vosha on 13.12.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        Group {
            if (sessionManager.currentUser != nil) {
                NavigationView {
                    HomeView()
                }
            } else {
                SignInOptionsView()
            }
        }
    }
}
