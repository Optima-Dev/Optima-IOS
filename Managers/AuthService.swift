import Foundation

class AuthService {
    static let shared = AuthService()
    
    private init() {}

    func signUpUser(firstName: String, lastName: String, email: String, password: String, role: String, completion: @escaping (Result<SignupResponse, AuthError>) -> Void) {
        let requestBody = SignupRequest(firstName: firstName, lastName: lastName, email: email, password: password, role: role)
        
        APIManager.shared.performRequest(
            url: APIEndpoints.signup,
            method: "POST",
            body: requestBody.asDictionary
        ) { (result: Result<SignupResponse, NetworkError>) in
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

extension Encodable {
    var asDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
    }
}
