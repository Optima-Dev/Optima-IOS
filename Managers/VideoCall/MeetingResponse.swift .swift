import Foundation

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
    let helper: String
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

struct MeetingTokenResponse: Codable {
    let status: String
    let data: TokenData
}

struct TokenData: Codable {
    let token: String
    let roomName: String
    let identity: String
}

struct PendingRequestResponse: Codable {
    let hasPending: Bool
}
