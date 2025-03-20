import Foundation

// MARK: - Authentication Models
// -----------------------------

/// Model for Signup Request
struct SignupRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let role: String
}

/// Model for Signup Response (Success: 200, Fail: 400)
struct SignupResponse: Codable {
    let token: String?      // Success case
    let message: String?    // Fail case
}

/// Model for Login Request
struct LoginRequest: Codable {
    let email: String
    let password: String
    let role: String
}

/// Model for Login Response (Success: 200, Fail: 400/401)
struct LoginResponse: Codable {
    let token: String?      // Success case
    let message: String?    // Fail case
}

// MARK: - Password Reset Models
// -----------------------------

/// Model for Send Code Request
struct SendCodeRequest: Codable {
    let email: String
}

/// Model for Send Code Response
struct SendCodeResponse: Codable {
    let message: String?
}

/// Model for Verify Code Request
struct VerifyCodeRequest: Codable {
    let email: String
    let code: String
}

/// Model for Verify Code Response
struct VerifyCodeResponse: Codable {
    let message: String?
}

/// Model for Reset Password Request
struct ResetPasswordRequest: Codable {
    let email: String
    let newPassword: String
}

/// Model for Reset Password Response
struct ResetPasswordResponse: Codable {
    let message: String?
}

// MARK: - User & Friends Models
// -----------------------------

/// Model for User Response (GET /users/me)
struct UserResponse: Codable {
    let user: User
}

/// Model for User Data
struct User: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // Map API's "_id" to "id"
        case firstName
        case lastName
        case email
    }
}

// Model for Friend Data
struct Friend: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    var isAdded: Bool? 
}

// Model for Friends List Response (GET /friends)
struct FriendsResponse: Decodable {
    let friends: [Friend]
}

// MARK: - Empty Response (For 204 No Content)
// -------------------------------------------
struct EmptyResponse: Decodable {}

// MARK: - Error Handling
// ----------------------
enum NetworkError: Error {
    case invalidURL
    case requestFailed(String)
    case decodingError
    case unauthorized    // 401
    case notFound        // 404
}

enum AuthError: Error {
    case failed(String)
}

