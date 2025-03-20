import Foundation

class UserManager {
    static let shared = UserManager()
    
    // MARK: - Fetch Current User
    func fetchCurrentUser(completion: @escaping (Result<User, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.unauthorized))
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
            completion(.failure(.unauthorized))
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

    // MARK: - Delete User (التعديل هنا)
    func deleteUser(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.unauthorized))
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
                AuthManager.shared.clearAuthData()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
