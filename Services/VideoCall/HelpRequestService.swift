import Foundation

class HelpRequestService {
    static let shared = HelpRequestService()
    private init() {}

    // Check if there's a pending help request (used in HelpRequestViewController)
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
        ) { (result: Result<PendingMeetingsResponse, NetworkError>) in
            switch result {
            case .success(let response):
                let hasPending = !response.data.meetings.isEmpty
                completion(.success(hasPending))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    //  Accept help request (used in HelperVideoCallViewController)
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
}
