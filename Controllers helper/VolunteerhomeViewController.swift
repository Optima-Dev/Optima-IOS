import UIKit

class VolunteerHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var waitingCountLabel: UILabel!

    var friends: [Friend] = []
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        configureTableView()
        loadUserData()
        loadData()
    }

    private func setupBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        tableView.backgroundColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func loadUserData() {
        UserManager.shared.fetchCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.userNameLabel.text = "Hello, \(user.firstName) \(user.lastName)!"
                case .failure(let error):
                    print("Error fetching user: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func refreshData() {
        loadData()
    }

    private func loadData() {
        let group = DispatchGroup()

        group.enter()
        FriendService.shared.fetchFriends { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let fetchedFriends):
                self?.friends = fetchedFriends.sorted { $0.firstName < $1.firstName }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error loading friends: \(error.localizedDescription)")
            }
        }

        group.enter()
        DispatchQueue.global().async {
            let randomCount = Int.random(in: 0...999)
            DispatchQueue.main.async {
                self.waitingCountLabel.text = "\(randomCount)"
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.updateContentViewHeight()
        }
    }

    private func updateContentViewHeight() {
        let tableViewHeight = tableView.contentSize.height
        contentView.frame.size.height = tableViewHeight + 100
        scrollView.contentSize = contentView.frame.size
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.isEmpty ? 1 : friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !friends.isEmpty else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
            cell.textLabel?.text = "No friends available"
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = .clear
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as? FriendListCell else {
            fatalError("Could not dequeue FriendListCell")
        }

        let friend = friends[indexPath.row]
        cell.configure(with: friend)
        cell.removeAction = { [weak self] in
            self?.handleRemoveFriend(friendId: friend.id, indexPath: indexPath)
        }
        return cell
    }

    private func handleRemoveFriend(friendId: String, indexPath: IndexPath) {
        FriendService.shared.removeFriend(friendId: friendId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.friends.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    self?.showAlert(message: "Error removing friend: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
