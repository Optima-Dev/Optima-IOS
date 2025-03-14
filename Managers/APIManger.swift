import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    // Fetch Friends with Authorization Token
    func fetchFriends(completion: @escaping (Result<[Friend], NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            completion(.failure(.requestFailed("Unauthorized: No Token Found")))
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]
        
        performRequest(url: APIEndpoints.fetchFriends, method: "GET", headers: headers) { (result: Result<FriendsResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response.friends))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // General function to perform API requests
    func performRequest<T: Decodable>(
        url: String,
        method: String,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let requestURL = URL(string: url) else {
            print("🔴 Invalid URL: \(url)")
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }

        print("🔹 Requesting: \(method) \(url)")
        print("🔹 Headers: \(request.allHTTPHeaderFields ?? [:])")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("🔴 Network Error: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                print("🔴 No data received")
                completion(.failure(.requestFailed("No data received")))
                return
            }

            print("🟢 Response Code: \(httpResponse.statusCode)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🟢 Raw Response: \(jsonString)")
            }

            if httpResponse.statusCode == 401 {
                print("🔴 Unauthorized! Redirecting to Login Screen...")
                completion(.failure(.requestFailed("Unauthorized Access")))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("🔴 Decoding Error: \(error)")
                completion(.failure(.decodingError))
            }
        }
        task.resume()
    }
}
