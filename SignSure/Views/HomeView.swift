//
//  HomeView.swift
//  SignSure
//
//  Created by Petrit Vosha on 13.12.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = SignInOptionsViewModel()

    var body: some View {
        VStack {
            if let user = sessionManager.currentUser {
                // Display user info
                Text("Welcome, \(user.firstName) \(user.lastName)!")
                    .font(.title)
                    .padding()

                // Display profile picture
                if let url = user.profilePictureURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // Sign Out Button
                Button(action: {
                    // Sign out from all services
                    viewModel.signOut(from: .google)
                    viewModel.signOut(from: .facebook)
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            } else {
                // Show sign-in options
                SignInOptionsView()
            }
        }
        .navigationTitle("Home")
        .onAppear {
            if let topVC = UIApplication.topViewController() {
                viewModel.presentingViewController = topVC
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SessionManager.shared)
    }
}
