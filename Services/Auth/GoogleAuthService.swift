import Foundation
import GoogleSignIn

class GoogleAuthService {
    static let shared = GoogleAuthService()
    
    private init() {}
    
    func signIn(with presentingViewController: UIViewController, completion: @escaping (Result<GIDGoogleUser, Error>) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = signInResult?.user else {
                completion(.failure(AuthError.failed("No user data")))
                return
            }
            
            completion(.success(user))
        }
    }
    
    func sendUserDataToAPI(user: GIDGoogleUser, completion: @escaping (Result<LoginResponse, AuthError>) -> Void) {
        guard let googleId = user.userID,
              let email = user.profile?.email,
              let firstName = user.profile?.givenName,
              let lastName = user.profile?.familyName else {
            completion(.failure(.failed("Missing user data")))
            return
        }
        
        let role = UserDefaults.standard.string(forKey: "userRole") ?? "helper"
        let requestBody: [String: Any] = [
            "googleId": googleId,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "role": role
        ]
        
        APIManager.shared.performRequest(
            url: APIEndpoints.google,
            method: "POST",
            body: requestBody
        ) { (result: Result<LoginResponse, NetworkError>) in
            switch result {
            case .success(let response):
                if let token = response.token {
                    print("🟢 Received Token: \(token)") // ✅ شوفي هل التوكين بيتسلم
                    AuthManager.shared.authToken = token // ✅ خزنيه في Keychain
                    print("🟢 Token saved in Keychain!") // ✅ تأكيد الحفظ
                    
                    completion(.success(response))
                } else {
                    completion(.failure(.failed("No token in response.")))
                }
            case .failure(let error):
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }
}
