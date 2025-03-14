struct APIEndpoints {
    static let baseURL = "https://optima-api.onrender.com/api"

    // Authentication
    static let signup = "\(baseURL)/auth/signup"
    static let login = "\(baseURL)/auth/login"
    static let google = "\(baseURL)/auth/google"
    static let sendCode = "\(baseURL)/auth/send-code"
    static let verifyCode = "\(baseURL)/auth/verify-code"
    static let resetPassword = "\(baseURL)/auth/reset-password"

    // User Profile
    static let fetchUser = "\(baseURL)/users/me"
    static let updateUser = "\(baseURL)/users/me"
    static let deleteUser = "\(baseURL)/users/me"

    // Friends
    static let fetchFriends = "\(baseURL)/friends/all"
    static let addFriend = "\(baseURL)/friends/send"
    static let removeFriend = "\(baseURL)/friends/remove"
    static let editFriend = "\(baseURL)/friends/edit"
}
