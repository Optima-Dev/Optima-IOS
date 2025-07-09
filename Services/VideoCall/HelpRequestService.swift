import Foundation

class HelpRequestService {
    static let shared = HelpRequestService()
    private init() {}

    // ✅ Check if there's a pending global meeting (FIXED)
    func checkPendingHelpRequest(completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.unauthorized))
            return
        }

        let endpoint = APIEndpoints.getPendingHelpRequest
        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "GET",
            headers: headers
        ) { (result: Result<GlobalMeetingsResponse, NetworkError>) in
            switch result {
            case .success(let response):
                let hasPending = !response.data.meetings.isEmpty
                completion(.success(hasPending))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // ✅ Accept first global meeting request
    func acceptHelpRequest(completion: @escaping (Result<MeetingTokenResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.unauthorized))
            return
        }

        let endpoint = APIEndpoints.acceptHelpRequest
        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "POST",
            headers: headers,
            completion: completion
        )
    }

    // ✅ Get all pending specific meeting requests
    func getPendingSpecificMeetings(completion: @escaping (Result<PendingMeetingsResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.unauthorized))
            return
        }

        let endpoint = APIEndpoints.getPendingSpecificMeetings
        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "GET",
            headers: headers,
            completion: completion
        )
    }

    // ✅ Accept a specific meeting by ID
    func acceptSpecificMeeting(meetingId: String, completion: @escaping (Result<MeetingTokenResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.unauthorized))
            return
        }

        let endpoint = APIEndpoints.acceptSpecificMeeting
        let headers = ["Authorization": "Bearer \(token)", "Content-Type": "application/json"]
        let body = ["meetingId": meetingId]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "POST",
            body: body,
            headers: headers,
            completion: completion
        )
    }

    // ✅ Reject a specific meeting by ID
    func rejectSpecificMeeting(meetingId: String, completion: @escaping (Result<MeetingResponse, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.unauthorized))
            return
        }

        let endpoint = APIEndpoints.rejectSpecificMeeting
        let headers = ["Authorization": "Bearer \(token)", "Content-Type": "application/json"]
        let body = ["meetingId": meetingId]

        APIManager.shared.performRequest(
            url: endpoint,
            method: "POST",
            body: body,
            headers: headers,
            completion: completion
        )
    }
}
