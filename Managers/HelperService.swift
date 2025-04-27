import Foundation

class HelperService {
    static let shared = HelperService()
    
    // MARK: - الحصول على عدد المنتظرين (إذا كان موجودًا في التوثيق)
    func getWaitingCount(completion: @escaping (Result<Int, NetworkError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }
        
        // 1. استبدل "your_actual_waiting_count_endpoint" بالمسار الصحيح من التوثيق
        let endpoint = "your_actual_waiting_count_endpoint"
        
        // 2. بناء الـ headers يدويًا دون استخدام authHeaders
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
