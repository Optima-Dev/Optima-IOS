import Foundation
import Security

// MARK: - Authentication Manager
class AuthManager {
    static let shared = AuthManager() // Singleton instance
    
    // MARK: - Token Management (Keychain)
    var authToken: String? {
        get {
            guard let tokenData = KeychainWrapper.retrieve(key: "authToken") else {
                print("🔴 No Token Found in Keychain!")
                return nil
            }
            return String(data: tokenData, encoding: .utf8)
        }
        set {
            if let token = newValue {
                let tokenData = token.data(using: .utf8)!
                let success = KeychainWrapper.save(key: "authToken", data: tokenData)
                print(success ? "🟢 Token saved successfully!" : "🔴 Failed to save token!")
            } else {
                let deleted = KeychainWrapper.delete(key: "authToken")
                print(deleted ? "🟢 Token deleted successfully!" : "🔴 Failed to delete token!")
            }
        }
    }
    
    // MARK: - User Role Management (UserDefaults)
    var userRole: String? {
        get { UserDefaults.standard.string(forKey: "userRole") }
        set {
            UserDefaults.standard.set(newValue, forKey: "userRole")
            print("🟢 User Role Saved: \(newValue ?? "None")")
        }
    }
    
    // MARK: - Clear All Auth Data
    func clearAuthData() {
        authToken = nil // Delete token from Keychain
        userRole = nil // Delete role from UserDefaults
        print("🟢 All authentication data cleared!")
    }
}
