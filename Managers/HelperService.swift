import Foundation

class HelperService {
    static let shared = HelperService()
    
    // MARK: - Fetch the number of users currently waiting (if available in documentation)
    func getWaitingCount(completion: @escaping (Result<Int, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }
        
        // 1. Replace "your_actual_waiting_count_endpoint" with the correct endpoint from the backend documentation
        let endpoint = "your_actual_waiting_count_endpoint"
        
        // 2. Build headers manually without using authHeaders helper
        let headers = ["Authorization": "Bearer \(token)"]
        
        APIManager.shared.performRequest(
            url: endpoint,
            method: "GET",
            headers: headers
        ) { (result: Result<Int, NetworkError>) in
            completion(result)
        }
    }
}
