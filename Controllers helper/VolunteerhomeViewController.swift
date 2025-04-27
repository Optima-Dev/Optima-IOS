import UIKit

class VolunteerHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var waitingCountLabel: UILabel!
    
    // MARK: - Properties
    var friends: [Friend] = []
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        configureTableView()
        loadData()
    }
    // MARK: - background Setup
    private func setupBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    // MARK: - Table Configuration
    private func configureTableView() {
        tableView.register(UINib(nibName: "FriendListCell", bundle: nil), forCellReuseIdentifier: "FriendListCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Loading
    @objc private func refreshData() {
        loadData()
    }
    
    private func loadData() {
        let group = DispatchGroup()
        
        // Load friends
        group.enter()
        FriendService.shared.fetchFriends { [weak self] (result: Result<[Friend], AuthError>) in
            defer { group.leave() }
            switch result {
            case .success(let friends):
                self?.friends = friends.sorted { $0.firstName < $1.firstName }
            case .failure(let error):
                print("Error loading friends: \(error.localizedDescription)")
            }
        }
        
        // Load waiting count (optional)
        group.enter()
        HelperService.shared.getWaitingCount { [weak self] (result: Result<Int, NetworkError>) in
            defer { group.leave() }
            if case .success(let count) = result {
                self?.waitingCountLabel.text = "\(count)"
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
            self?.updateContentViewHeight()
        }
    }
    
    // MARK: - Layout Updates
    private func updateContentViewHeight() {
        let tableViewHeight = tableView.contentSize.height
        contentView.frame.size.height = tableViewHeight + 100 // Add padding
        scrollView.contentSize = contentView.frame.size
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    // MARK: - Friend Removal
    private func handleRemoveFriend(friendId: String, indexPath: IndexPath) {
        FriendService.shared.removeFriend(friendId: friendId) { [weak self] (result: Result<Void, AuthError>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.friends.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.updateContentViewHeight()
                case .failure(let error):
                    self?.showAlert(message: "Error removing friend: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Alert Helper
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
