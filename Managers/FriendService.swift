import Foundation

class FriendService {
    static let shared = FriendService()
    
    // MARK: - Existing Friend Management
    func sendFriendRequest(customFirstName: String, customLastName: String, helperEmail: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.failed("Unauthorized")))
        }
        
        let body: [String: Any] = [
            "customFirstName": customFirstName,
            "customLastName": customLastName,
            "helperEmail": helperEmail
        ]
        
        APIManager.shared.performRequest(
            url: APIEndpoints.addFriend,
            method: "POST",
            body: body,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<EmptyResponse, NetworkError>) in
            switch result {
            case .success:
                completion(.success("Request sent"))
            case .failure(let error):
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }
    
    // MARK: - New Friend Request Handling
    func fetchFriendRequests(completion: @escaping (Result<[FriendRequest], AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.failed("Unauthorized")))
        }
        
        APIManager.shared.performRequest(
            url: APIEndpoints.fetchFriendRequests,
            method: "GET",
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<[FriendRequest], NetworkError>) in
            switch result {
            case .success(let requests):
                completion(.success(requests))
            case .failure(let error):
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }
    
    func acceptFriendRequest(requestId: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.failed("Unauthorized")))
        }
        
        APIManager.shared.performRequest(
            url: APIEndpoints.acceptFriendRequest,
            method: "POST",
            body: ["requestId": requestId],
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<EmptyResponse, NetworkError>) in
            switch result {
            case .success:
                completion(.success("Request accepted"))
            case .failure(let error):
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }
    
    func declineFriendRequest(requestId: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.failed("Unauthorized")))
        }
        
        APIManager.shared.performRequest(
            url: APIEndpoints.declineFriendRequest,
            method: "POST",
            body: ["requestId": requestId],
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<EmptyResponse, NetworkError>) in
            switch result {
            case .success:
                completion(.success("Request declined"))
            case .failure(let error):
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }
    
    // MARK: - Added Missing Functions
    func fetchFriends(completion: @escaping (Result<[Friend], AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.failed("Unauthorized")))
        }
        
        APIManager.shared.performRequest(
            url: APIEndpoints.fetchFriends,
            method: "GET",
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<[Friend], NetworkError>) in
            switch result {
            case .success(let friends):
                completion(.success(friends))
            case .failure(let error):
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }
    
    func removeFriend(friendId: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.failed("Unauthorized")))
        }
        
        APIManager.shared.performRequest(
            url: APIEndpoints.removeFriend,
            method: "POST",
            body: ["friendId": friendId],
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<EmptyResponse, NetworkError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }

    func updateFriend(friendId: String, firstName: String, lastName: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.failed("Unauthorized")))
        }
        
        let parameters: [String: Any] = [
            "friendId": friendId,
            "customFirstName": firstName,
            "customLastName": lastName
        ]
        
        APIManager.shared.performRequest(
            url: APIEndpoints.editFriend,
            method: "POST",
            body: parameters,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<EmptyResponse, NetworkError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(.failed(error.localizedDescription)))
            }
        }
    }
}
