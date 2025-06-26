import Foundation

class MeetingService {
    static let shared = MeetingService()
    
    private init() {}

    // ✅ Create a new meeting (Seeker side)
    func createMeeting(type: String, helperId: String? = nil, completion: @escaping (Result<MeetingTokenResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        let endpoint = APIEndpoints.createMeeting
        var body: [String: Any] = ["type": type]
        if let helperId = helperId {
            body["helper"] = helperId
        }

        let headers = ["Authorization": "Bearer \(token)", "Content-Type": "application/json"]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "POST",
            body: body,
            headers: headers,
            completion: completion
        )
    }

    // ✅ End meeting with meetingId (Seeker side)
    func endMeeting(meetingId: String, completion: @escaping (Result<MeetingResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        let endpoint = APIEndpoints.endMeeting
        let headers = ["Authorization": "Bearer \(token)"]
        let body: [String: Any] = ["meetingId": meetingId]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "POST",
            body: body,
            headers: headers,
            completion: completion
        )
    }

    // ✅ End meeting for current user (Helper side)
    func endMeetingForCurrentUser(completion: @escaping (Result<MeetingResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        let endpoint = APIEndpoints.endMeeting
        let headers = ["Authorization": "Bearer \(token)"]
        let body: [String: Any] = [:]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "POST",
            body: body,
            headers: headers,
            completion: completion
        )
    }

    // ✅ Get meeting details
    func getMeetingDetails(meetingId: String, completion: @escaping (Result<MeetingResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        let endpoint = "\(APIEndpoints.getMeetingDetails)/\(meetingId)"
        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "GET",
            headers: headers,
            completion: completion
        )
    }
}
