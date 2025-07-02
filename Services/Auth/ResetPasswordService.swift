import Foundation

class ResetPasswordService {
    static let shared = ResetPasswordService()
    
    private init() {}

    func sendCode(to email: String, completion: @escaping (Result<SendCodeResponse, AuthError>) -> Void) {
        let requestBody = SendCodeRequest(email: email)
        
        APIManager.shared.performRequest(
            url: APIEndpoints.sendCode,
            method: "POST",
            body: requestBody.asDictionary
        ) { (result: Result<SendCodeResponse, NetworkError>) in
            switch result {
            case .success(let response):
                if response.message == "Code sent successfully" { // Success case (status 200)
                    print("✅ Code sent successfully")
                    completion(.success(response))
                } else if let errorMessage = response.message { // Error case (status 400, 404, 500)
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

    func verifyCode(email: String, code: String, completion: @escaping (Result<VerifyCodeResponse, AuthError>) -> Void) {
        let requestBody = VerifyCodeRequest(email: email, code: code)
        
        APIManager.shared.performRequest(
            url: APIEndpoints.verifyCode,
            method: "POST",
            body: requestBody.asDictionary
        ) { (result: Result<VerifyCodeResponse, NetworkError>) in
            switch result {
            case .success(let response):
                if response.message == "Code verified" { // Success case (status 200)
                    print("✅ Code verified")
                    completion(.success(response))
                } else if let errorMessage = response.message { // Error case (status 400, 404)
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

    func resetPassword(email: String, newPassword: String, completion: @escaping (Result<ResetPasswordResponse, AuthError>) -> Void) {
        let requestBody = ResetPasswordRequest(email: email, newPassword: newPassword)
        
        APIManager.shared.performRequest(
            url: APIEndpoints.resetPassword,
            method: "POST",
            body: requestBody.asDictionary
        ) { (result: Result<ResetPasswordResponse, NetworkError>) in
            switch result {
            case .success(let response):
                if response.message == "Password reset successfully" { // Success case (status 200)
                    print("✅ Password reset successfully")
                    completion(.success(response))
                } else if let errorMessage = response.message { // Error case (status 400, 404)
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
