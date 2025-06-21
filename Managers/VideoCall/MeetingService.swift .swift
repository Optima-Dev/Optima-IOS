import Foundation

class MeetingService {
    static let shared = MeetingService()
    
    private init() {}

    // Create a new meeting (used by seeker)
    func createMeeting(type: String, helperId: String, completion: @escaping (Result<MeetingResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        let endpoint = APIEndpoints.createMeeting
        let headers = ["Authorization": "Bearer \(token)"]
        let body: [String: Any] = [
            "type": type,
            "helper": helperId
        ]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "POST",
            body: body,
            headers: headers,
            completion: completion
        )
    }

    // Generate access token for joining a meeting
    func generateToken(meetingId: String, completion: @escaping (Result<MeetingTokenResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        let endpoint = APIEndpoints.generateToken
        let headers = ["Authorization": "Bearer \(token)"]
        let body: [String: Any] = [
            "meetingId": meetingId
        ]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "POST",
            body: body,
            headers: headers,
            completion: completion
        )
    }

    // End an ongoing meeting
    func endMeeting(meetingId: String, completion: @escaping (Result<MeetingResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        let endpoint = APIEndpoints.endMeeting
        let headers = ["Authorization": "Bearer \(token)"]
        let body: [String: Any] = [
            "meetingId": meetingId
        ]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "POST",
            body: body,
            headers: headers,
            completion: completion
        )
    }

    // Optional: Get meeting details by ID
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
