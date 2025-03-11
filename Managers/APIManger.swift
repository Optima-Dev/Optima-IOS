import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    func performRequest<T: Decodable>(
        url: String,
        method: String,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil, // إضافة الـ Headers
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let requestURL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // إضافة الـ Headers إذا وجدت
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestFailed("No data received")))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔹 Raw Response: \(jsonString)")
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
