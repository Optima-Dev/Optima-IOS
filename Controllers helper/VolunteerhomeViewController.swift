import UIKit

class VolunteerHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var friends: [Friend] = [
        Friend(id: "1", firstName: "Anwar", lastName: "Jacobi", email: "anwar@example.com", isAdded: true),
        Friend(id: "2", firstName: "Sabrina", lastName: "Donnelly", email: "sabrina@example.com", isAdded: false),
        Friend(id: "3", firstName: "Ayman", lastName: "Salah", email: "ayman@example.com", isAdded: true),
        Friend(id: "4", firstName: "Nour", lastName: "Hassan", email: "nour@example.com", isAdded: false)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ✅ Set tableView delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        // ✅ Hide tableView separators to match the design
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        // ✅ Set background image
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        
        // ✅ Reload tableView and update contentView height after loading data
        tableView.reloadData()
        updateContentViewHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentViewHeight()
    }

    // ✅ Dynamically adjust contentView height based on tableView content size
    func updateContentViewHeight() {
        contentView.frame.size.height = tableView.contentSize.height + 40 // Extra padding for spacing
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView.frame.height)
    }

    // ✅ Return the number of rows in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    // ✅ Configure tableView cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell") as? FriendListCell else {
            fatalError("Error: Could not dequeue FriendListCell")
        }
        
        let friend = friends[indexPath.row]
        cell.nameLabel.text = "\(friend.firstName) \(friend.lastName)"
        cell.updateButtonState(isAdded: friend.isAdded ?? false)

        return cell
    }

    // ✅ Set cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Adjust cell height as needed
    }

    // ✅ Add spacing between tableView cells
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20 // Space between cells
    }
}
