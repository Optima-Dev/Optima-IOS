import Foundation

// MARK: - Create Meeting + Accept Meeting

struct MeetingResponse: Codable {
    let status: String
    let data: MeetingData
}

struct MeetingData: Codable {
    let meeting: Meeting
}

struct Meeting: Codable {
    let id: String
    let seeker: String
    let helper: String?
    let type: String
    let status: String
    let createdAt: String?
    let acceptedAt: String?
    let endedAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case seeker, helper, type, status, createdAt, acceptedAt, endedAt, updatedAt
    }
}

// MARK: - Token Generation (FIXED status type)

struct MeetingTokenResponse: Codable {
    let status: String  // ✅ FIXED from Int to String
    let message: String?
    let data: TokenData?
}

struct TokenData: Codable {
    let token: String
    let roomName: String
    let identity: String
}

// MARK: - Check if Pending Global Help Request Exists

struct PendingRequestResponse: Codable {
    let hasPending: Bool
}

// MARK: - Get List of Pending Specific Help Requests

struct PendingMeetingsResponse: Codable {
    let data: MeetingsData
}

struct MeetingsData: Codable {
    let meetings: [PendingMeeting]
}

struct PendingMeeting: Codable {
    let id: String
    let seeker: String
    let seekerName: String?
    let type: String
    let helper: String?
    let status: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case seeker, seekerName, type, helper, status, createdAt, updatedAt
    }
}
