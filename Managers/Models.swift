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
    let role: String
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let token: String? //success (status 200)
    let message: String? // fail (status 400,401)
  //  let role: String?
}
// MARK: - Send Code Request
struct SendCodeRequest: Codable {
    let email: String
}

// MARK: - Send Code Response
struct SendCodeResponse: Codable {
    let message: String?
}

// MARK: - Verify Code Request
struct VerifyCodeRequest: Codable {
    let email: String
    let code: String
}

// MARK: - Verify Code Response
struct VerifyCodeResponse: Codable {
    let message: String?
}

// MARK: - Reset Password Request
struct ResetPasswordRequest: Codable {
    let email: String
    let newPassword: String
}
// MARK: - Reset Password Response
struct ResetPasswordResponse: Codable {
    let message: String?
}
// MARK: - UserResponse 
struct UserResponse: Codable {
    let user: User
}

// MARK: - User Model
struct User: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case email
    }
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
