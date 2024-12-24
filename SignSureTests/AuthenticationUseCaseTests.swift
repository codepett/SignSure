//
//  AuthenticationUseCaseTests.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import XCTest
import Combine
@testable import SignSure

class AuthenticationUseCaseTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var authenticationUseCase: AuthenticationUseCase!
    var mockAuthService: AuthService!

    override func setUp() {
        super.setUp()
        cancellables = []
        let mockOAuthService = OAuthService(
            googleProvider: MockGoogleOAuthProvider(),
            facebookProvider: MockFacebookOAuthProvider()
        )
        mockAuthService = AuthService(oauthService: mockOAuthService)
        authenticationUseCase = AuthenticationUseCase(authService: mockAuthService)
    }

    override func tearDown() {
        cancellables = nil
        authenticationUseCase = nil
        mockAuthService = nil
        super.tearDown()
    }

    func testGoogleSignInSuccess() {
        let expectation = self.expectation(description: "Google Sign-In Success")

        authenticationUseCase.signIn(with: .google, presentingViewController: UIViewController())
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but got failure with \(error)")
                }
            }, receiveValue: { user in
                XCTAssertEqual(user.email, "test@example.com")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 5, handler: nil)
    }

    // Additional tests for failure scenarios...
}
