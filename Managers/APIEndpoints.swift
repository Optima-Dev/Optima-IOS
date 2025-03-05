struct APIEndpoints {
    static let baseURL = "https://optima-api.onrender.com/api/auth"

    static let signup = "\(baseURL)/signup"
    static let login = "\(baseURL)/login"
    static let google = "\(baseURL)/google" 
    static let sendCode = "\(baseURL)/send-code"
    static let verifyCode = "\(baseURL)/verify-code"
    static let resetPassword = "\(baseURL)/reset-password"
}
