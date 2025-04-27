import Foundation

// MARK: - Authentication Models
struct SignupRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let role: String
}

struct SignupResponse: Codable {
    let token: String?
    let message: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
    let role: String
}

struct LoginResponse: Codable {
    let token: String?
    let message: String?
}

// MARK: - Password Reset Models
struct SendCodeRequest: Codable {
    let email: String
}

struct SendCodeResponse: Codable {
    let message: String?
}

struct VerifyCodeRequest: Codable {
    let email: String
    let code: String
}

struct VerifyCodeResponse: Codable {
    let message: String?
}

struct ResetPasswordRequest: Codable {
    let email: String
    let newPassword: String
}

struct ResetPasswordResponse: Codable {
    let message: String?
}

// MARK: - User & Friends Models
struct UserResponse: Codable {
    let user: User
}

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

struct Friend: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    var isAdded: Bool?
}

struct FriendsResponse: Codable {
    let friends: [Friend]
}
// MARK: - Empty Response
struct EmptyResponse: Decodable {}
// MARK: - Error Handling
enum NetworkError: Error {
    case invalidURL
    case requestFailed(String)
    case decodingError
    case unauthorized
    case notFound
}

enum AuthError: Error {
    case failed(String)
}
