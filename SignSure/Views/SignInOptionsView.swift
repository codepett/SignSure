//
//  SignInOptionsView.swift
//  SignSure
//
//  Created by Petrit Vosha on 24.12.2024.
//

import SwiftUI
import Combine

struct SignInOptionsView: View {
    @StateObject private var viewModel = SignInOptionsViewModel()
    
    // For showing an alert if we fail to find a top-level UIViewController or encounter another error
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Welcome to SignSure!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            if viewModel.isLoading {
                ProgressView("Signing In...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                // GOOGLE SIGN-IN BUTTON
                Button(action: {
                    attemptSignIn(service: .google)
                }) {
                    HStack(spacing: 12) {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        Text("Continue with Google")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(.darkGray))
                    }
                    .padding(.trailing, 8)
                    .frame(width: UIScreen.main.bounds.width - 64, height: 60)
                    .background(Color(red: 249/255, green: 249/255, blue: 249/255))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                }
                .buttonStyle(.plain)

                // FACEBOOK SIGN-IN BUTTON
                Button(action: {
                    attemptSignIn(service: .facebook)
                }) {
                    HStack(spacing: 12) {
                        Image("facebook_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)

                        Text("Continue with Facebook")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(.darkGray))
                    }
                    .padding(.trailing, 8)
                    .frame(width: UIScreen.main.bounds.width - 64, height: 60)
                    .background(Color(red: 249/255, green: 249/255, blue: 249/255))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                }
                .buttonStyle(.plain)

            }

            Spacer()
        }
        .navigationTitle("Authenticate")
        .navigationBarHidden(true)
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Authentication Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        // Using a second alert for errors coming from the ViewModel
        .alert(item: $viewModel.authError) { authError in
            Alert(
                title: Text("Authentication Error"),
                message: Text(authError.errorDescription ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Attempt to set the presenting view controller right when the view appears
            if let topVC = UIApplication.topViewController() {
                viewModel.presentingViewController = topVC
            }
        }
    }
    
    /// Attempts sign-in using the specified OAuth service.
    /// - Parameter service: The OAuth service type (Google, Facebook).
    private func attemptSignIn(service: OAuthServiceType) {
        // Ensure we have a valid presenting view controller
        guard let topVC = UIApplication.topViewController() else {
            errorMessage = "Unable to find presenting view controller."
            showErrorAlert = true
            return
        }
        
        // Update the ViewModel’s presenting view controller (in case it changed)
        viewModel.presentingViewController = topVC
        
        // Trigger the sign-in flow
        viewModel.signIn(with: service)
    }
}

// MARK: - Previews
struct SignInOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignInOptionsView()
                .environmentObject(SessionManager.shared) // Provide environment object if needed
        }
    }
}
