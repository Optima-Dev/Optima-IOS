import Foundation
import Security

class AuthManager {
    static let shared = AuthManager()
    
    var authToken: String? {
        get {
            guard let data = KeychainWrapper.retrieve(key: "authToken") else {
                print("🔴 No Token Found in Keychain!")
                return nil
            }
            return String(data: data, encoding: .utf8)
        }
        set {
            if let token = newValue {
                let data = token.data(using: .utf8)!
                let success = KeychainWrapper.save(key: "authToken", data: data)
                if success {
                    print("🟢 Token saved successfully!")
                } else {
                    print("🔴 Failed to save token!")
                }
            } else {
                let deleted = KeychainWrapper.delete(key: "authToken")
                if deleted {
                    print("🟢 Token deleted successfully!")
                } else {
                    print("🔴 Failed to delete token!")
                }
            }
        }
    }

    var userRole: String? {
        get { UserDefaults.standard.string(forKey: "userRole") }
        set {
            UserDefaults.standard.set(newValue, forKey: "userRole")
            print("🟢 User Role Saved: \(newValue ?? "None")")
        }
    }

    func clearAuthData() {
        authToken = nil
        userRole = nil
    }
}
