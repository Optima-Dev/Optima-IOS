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
    
    // Friend Requests 
    static let fetchFriendRequests = "\(baseURL)/friends/requests"
    static let acceptFriendRequest = "\(baseURL)/friends/accept"
    static let declineFriendRequest = "\(baseURL)/friends/reject"
    
    // Meetings
    static let createMeeting = "\(baseURL)/meetings"
    static let endMeeting = "\(baseURL)/meetings/end"
    static let getMeetingDetails = "\(baseURL)/meetings"
    
    // Helper Help Requests
    static let getPendingHelpRequest = "\(baseURL)/meetings/global"
    static let acceptHelpRequest = "\(baseURL)/meetings/accept-first"
    static let getPendingSpecificMeetings = "\(baseURL)/meetings/pending-specific"
    static let acceptSpecificMeeting = "\(baseURL)/meetings/accept-specific"
    static let rejectSpecificMeeting = "\(baseURL)/meetings/reject"
}
