import Foundation

class LoginService {
    static let shared = LoginService()
    
    private init() {}

    func loginUser(email: String, password: String, completion: @escaping (Result<LoginResponse, AuthError>) -> Void) {
        let requestBody = LoginRequest(email: email, password: password)
        
        APIManager.shared.performRequest(
            url: APIEndpoints.login,
            method: "POST",
            body: requestBody.asDictionary
        ) { (result: Result<LoginResponse, NetworkError>) in
            switch result {
            case .success(let response):
                if let token = response.token { // Success case (status 200)
                    print("✅ Login Successful, Token: \(token)")
                    UserDefaults.standard.set(token, forKey: "authToken")
                    completion(.success(response))
                } else if let errorMessage = response.message { // Error case (status 400 or 401)
                    print("🔴 Error: \(errorMessage)")
                    completion(.failure(.failed(errorMessage)))
                } else {
                    print("🔴 Unknown Error")
                    completion(.failure(.failed("Unknown error occurred")))
                }
            case .failure(let error):
                print("🔴 Network Error: \(error.localizedDescription)")
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }
}
