import Foundation

class LoginService {
    static let shared = LoginService()
    
    private init() {}

    func loginUser(email: String, password: String, completion: @escaping (Result<LoginResponse, AuthError>) -> Void) {
        let role = UserDefaults.standard.string(forKey: "userRole") ?? "helper"
        let requestBody = LoginRequest(email: email, password: password, role: role)
        
        APIManager.shared.performRequest(
            url: APIEndpoints.login,
            method: "POST",
            body: requestBody.asDictionary
        ) { (result: Result<LoginResponse, NetworkError>) in
            switch result {
            case .success(let response):
                if let token = response.token {
                    UserDefaults.standard.set(token, forKey: "authToken")
                    completion(.success(response))
                } else if let errorMessage = response.message {
                    completion(.failure(.failed(errorMessage)))
                } else {
                    completion(.failure(.failed("Unknown error occurred")))
                }
            case .failure(let error):
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }
}
