import Foundation

class UserManager {
    static let shared = UserManager()
    private let baseURL = "https://optima-api.onrender.com/api/users"
    
    // MARK: - Fetch Current User
    func fetchCurrentUser(completion: @escaping (Result<User, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.requestFailed("Unauthorized")))
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        APIManager.shared.performRequest(
            url: "\(baseURL)/me",
            method: "GET",
            headers: headers,
            completion: completion
        )
    }
    
    // MARK: - Update User
    func updateUser(firstName: String, lastName: String, email: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.requestFailed("Unauthorized")))
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        let body: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email
        ]
        
        APIManager.shared.performRequest(
            url: "\(baseURL)/me",
            method: "PUT",
            body: body,
            headers: headers,
            completion: completion
        )
    }
    
    // MARK: - Delete User
    func deleteUser(completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.requestFailed("Unauthorized")))
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        APIManager.shared.performRequest(
            url: "\(baseURL)/me",
            method: "DELETE",
            headers: headers
        ) { (result: Result<EmptyResponse, NetworkError>) in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Empty Response for DELETE
struct EmptyResponse: Decodable {}
