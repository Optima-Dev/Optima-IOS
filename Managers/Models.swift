import Foundation

// MARK: - Signup Request
struct SignupRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let role: String
}

// MARK: - Signup Response
struct SignupResponse: Codable {
    let token: String? //success (status 200)
    let message: String? // fail (status 400)
}

// MARK: - Login Request
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let token: String? //success (status 200)
    let message: String? // fail (status 400,401)
}
// MARK: - Network Error
enum NetworkError: Error {
    case invalidURL
    case requestFailed(String)
    case decodingError
}

// MARK: - Auth Error
enum AuthError: Error {
    case failed(String)
}
