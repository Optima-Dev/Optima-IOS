import Foundation

class FriendService {
    static let shared = FriendService()

    // Send Friend Request
    func sendFriendRequest(customFirstName: String, customLastName: String, helperEmail: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
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
                completion(.failure(.networkError(error)))
            }
        }
    }

    // Fetch Friend Requests
    func fetchFriendRequests(completion: @escaping (Result<[FriendRequest], AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        APIManager.shared.performRequest(
            url: APIEndpoints.fetchFriendRequests,
            method: "GET",
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<[String: [FriendRequest]], NetworkError>) in
            switch result {
            case .success(let response):
                let requests = response["friendRequests"] ?? []
                completion(.success(requests))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }

    // Accept Friend Request
    func acceptFriendRequest(requestId: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
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
                completion(.failure(.networkError(error)))
            }
        }
    }

    // Decline Friend Request
    func declineFriendRequest(requestId: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
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
                completion(.failure(.networkError(error)))
            }
        }
    }

    // Remove Friend
    func removeFriend(friendId: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
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
                completion(.failure(.networkError(error)))
            }
        }
    }

    // Update Friend
    func updateFriend(friendId: String, firstName: String, lastName: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        let parameters: [String: Any] = [
            "friendId": friendId,
            "customFirstName": firstName,
            "customLastName": lastName
        ]

        APIManager.shared.performRequest(
            url: APIEndpoints.editFriend,
            method: "PUT",
            body: parameters,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<EmptyResponse, NetworkError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }

    // Fetch Friends for Volunteer (custom names if available)
    func fetchFriends(completion: @escaping (Result<[Friend], AuthError>) -> Void) {
        guard let token = AuthManager.shared.authToken else {
            return completion(.failure(.unauthorized))
        }

        APIManager.shared.performRequest(
            url: APIEndpoints.fetchFriends,
            method: "GET",
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<[String: [FriendWrapper]], NetworkError>) in
            switch result {
            case .success(let response):
                let wrappers = response["friends"] ?? []
                let friends = wrappers.map {
                    Friend(
                        id: $0.user.id,
                        firstName: $0.customFirstName ?? $0.user.firstName,
                        lastName: $0.customLastName ?? $0.user.lastName,
                        email: $0.user.email
                    )
                }
                completion(.success(friends))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
}
