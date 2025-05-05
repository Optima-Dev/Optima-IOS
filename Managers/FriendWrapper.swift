import Foundation

struct FriendWrapper: Codable {
    let customFirstName: String?
    let customLastName: String?
    let user: FriendUser
}

struct FriendUser: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case email
    }
}
