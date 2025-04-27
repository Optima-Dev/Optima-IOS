import Foundation

struct FriendRequest: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    var status: String  // "pending", "accepted", "declined" 
}
