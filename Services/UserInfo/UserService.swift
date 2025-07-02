import Foundation

class UserService {
    static let shared = UserService()
    
    func fetchCurrentUser(completion: @escaping (Result<User, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }
        
        APIManager.shared.performRequest(
            url: APIEndpoints.fetchUser,
            method: "GET",
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<User, NetworkError>) in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
}
