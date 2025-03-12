import Foundation

class UserManager {
    static let shared = UserManager()
    
    // MARK: - Fetch Current User
    func fetchCurrentUser(completion: @escaping (Result<User, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.requestFailed("Unauthorized: No Token Found")))
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.performRequest(
            url: APIEndpoints.fetchUser,
            method: "GET",
            headers: headers
        ) { (result: Result<UserResponse, NetworkError>) in
            switch result {
            case .success(let userResponse):
                completion(.success(userResponse.user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Update User
    func updateUser(firstName: String?, lastName: String?, email: String?, completion: @escaping (Result<User, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.requestFailed("Unauthorized: No Token Found")))
            return
        }

        var body: [String: Any] = [:]
        if let firstName = firstName { body["firstName"] = firstName }
        if let lastName = lastName { body["lastName"] = lastName }
        if let email = email { body["email"] = email }

        if body.isEmpty {
            completion(.failure(.requestFailed("No changes detected")))
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.performRequest(
            url: APIEndpoints.updateUser,
            method: "PUT",
            body: body,
            headers: headers,
            completion: completion
        )
    }

    // MARK: - Delete User
    func deleteUser(completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.requestFailed("Unauthorized: No Token Found")))
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.performRequest(
            url: APIEndpoints.deleteUser,
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
