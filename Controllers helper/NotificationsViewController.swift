import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var friendRequests: [String] = ["User 1", "User 2", "User 3"]
    var acceptedRequests: [Bool] = [false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .clear
        tableView.isOpaque = false
        tableView.backgroundView = nil

        setupBackgroundImage()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.separatorStyle = .none
    }

    private func setupBackgroundImage() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestCell
        let userName = friendRequests[indexPath.row]
        let isAccepted = acceptedRequests[indexPath.row]
        cell.configureCell(with: userName, isAccepted: isAccepted)

        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        cell.acceptAction = {
            self.acceptedRequests[indexPath.row] = true
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.removeAction = {
            self.acceptedRequests[indexPath.row] = false
            
            DispatchQueue.main.async {
                if let cell = tableView.cellForRow(at: indexPath) as? FriendRequestCell {
                    cell.removeButton.setTitle("Removed", for: .normal)
                    cell.removeButton.setTitleColor(UIColor(hex: "#2727C4"), for: .normal)
                    cell.removeButton.layer.borderWidth = 2
                    cell.removeButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor
                    cell.removeButton.backgroundColor = .clear
                    cell.removeButton.isEnabled = false
                }
            }
        }

        return cell
    }
}
