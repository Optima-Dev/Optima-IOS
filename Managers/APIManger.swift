import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    // MARK: - Fetch Friends
    func fetchFriends(completion: @escaping (Result<[Friend], NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.unauthorized))
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]
        
        performRequest(url: APIEndpoints.fetchFriends, method: "GET", headers: headers) {
            (result: Result<FriendsResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response.friends))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Generic Request Handler
    func performRequest<T: Decodable>(
        url: String,
        method: String,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // 1. Validate URL
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 2. Add Headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 3. Add Body
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }

        print("🔹 Request: \(method) \(url)")
        print("🔹 Headers: \(request.allHTTPHeaderFields ?? [:])")

        // 4. Start Data Task
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 5. Handle Network Errors
            if let error = error {
                print("🔴 Network Error: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }

            // 6. Validate Response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed("Invalid response format")))
                return
            }

            print("🟢 Response Code: \(httpResponse.statusCode)")

            // 7. Handle Specific Status Codes
            switch httpResponse.statusCode {
            case 401:
                print("🔴 Unauthorized! Clearing auth data...")
                AuthManager.shared.clearAuthData()
                completion(.failure(.unauthorized))
                return
            case 404:
                completion(.failure(.notFound))
                return
            case 204 where T.self == EmptyResponse.self:
                completion(.success(EmptyResponse() as! T))
                return
            default:
                break
            }

            // 8. Handle Empty Data (204 No Content)
            guard let data = data, !data.isEmpty else {
                completion(.failure(.decodingError))
                return
            }

            // 9. Debug Raw Response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🟢 Raw Response: \(jsonString)")
            }

            // 10. Decode Response
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("🔴 Decoding Error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
