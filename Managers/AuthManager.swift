import Foundation
import Security

class AuthManager {
    static let shared = AuthManager()
    
    // MARK: - Keychain Handling
    var authToken: String? {
        get {
            guard let data = KeychainWrapper.retrieve(key: "authToken") else { return nil }
            return String(data: data, encoding: .utf8)
        }
        set {
            if let token = newValue {
                let data = token.data(using: .utf8)!
                if !KeychainWrapper.save(key: "authToken", data: data) {
                    print("🔴 Failed to save token!")
                }
            } else {
                if !KeychainWrapper.delete(key: "authToken") {
                    print("🔴 Failed to delete token!")
                }
            }
        }
    }
    
    // MARK: - User Role Handling
    var userRole: String? {
        get { UserDefaults.standard.string(forKey: "userRole") }
        set { UserDefaults.standard.set(newValue, forKey: "userRole") }
    }
    
    // MARK: - Clear Data
    func clearAuthData() {
        authToken = nil
        userRole = nil
    }
}


