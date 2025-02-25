//
//  AuthService.swift
//  Optima
//
//  Created by Ghada Abdelrahman on 20/02/2025.
//

import Foundation

class AuthService {
    
    static let shared = AuthService()  // Singleton instance

    private init() {}  // Prevent direct initialization

    // MARK: - Login Request (To be implemented with real API)
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        // TODO: Replace this with actual API request when Backend is ready
        print("🔄 Attempting to login with email: \(email)")

        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { // Simulating network delay
            if email == "test@example.com" && password == "Test@1234" {
                completion(true, nil)  // Success
            } else {
                completion(false, "Invalid email or password.")  // Failure
            }
        }
    }
}
