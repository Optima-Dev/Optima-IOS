import Foundation

// MARK: - Create Meeting + Accept Meeting (Shared)
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

// MARK: - Token Generation
struct MeetingTokenResponse: Codable {
    let status: String
    let message: String?
    let data: TokenData?
}

struct TokenData: Codable {
    let token: String
    let roomName: String
    let identity: String
    let meeting: Meeting?

    var meetingId: String? {
        return meeting?.id
    }
}

// MARK: - Check if Pending Global Help Request Exists
// ✅ Use this when just checking if there's any pending global request
struct PendingRequestResponse: Codable {
    let hasPending: Bool
}

// ✅ Use this if getting full data of pending global meetings
struct GlobalMeetingsResponse: Codable {
    let data: GlobalMeetingsData
}

struct GlobalMeetingsData: Codable {
    let meetings: [GlobalMeeting]
}

struct GlobalMeeting: Codable {
    let id: String
    let seeker: String
    let type: String
    let status: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case seeker, type, status, createdAt, updatedAt
    }
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

    enum OuterKeys: String, CodingKey {
        case _doc, seekerName
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case seeker, type, helper, status, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OuterKeys.self)
        let doc = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: ._doc)

        id = try doc.decode(String.self, forKey: .id)
        seeker = try doc.decode(String.self, forKey: .seeker)
        type = try doc.decode(String.self, forKey: .type)
        helper = try doc.decodeIfPresent(String.self, forKey: .helper)
        status = try doc.decode(String.self, forKey: .status)
        createdAt = try doc.decode(String.self, forKey: .createdAt)
        updatedAt = try doc.decode(String.self, forKey: .updatedAt)

        seekerName = try container.decodeIfPresent(String.self, forKey: .seekerName)
    }
}
