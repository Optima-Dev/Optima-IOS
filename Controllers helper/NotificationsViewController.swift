import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var friendRequests: [FriendRequest] = []
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTableView()
        loadFriendRequests()
    }
    // MARK: - background Setup
    private func setupBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    // MARK: - TableView Setup
    private func setupTableView() {
        tableView.register(UINib(nibName: "FriendRequestCell", bundle: nil), forCellReuseIdentifier: "FriendRequestCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Loading
    @objc private func refreshData() {
        loadFriendRequests()
    }
    
    private func loadFriendRequests() {
        FriendService.shared.fetchFriendRequests { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                switch result {
                case .success(let requests):
                    self?.friendRequests = requests
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestCell
        let request = friendRequests[indexPath.row]
        cell.configure(with: request)
        
        cell.acceptAction = { [weak self] in
            self?.handleAcceptRequest(requestId: request.id)
        }
        
        cell.declineAction = { [weak self] in
            self?.handleDeclineRequest(requestId: request.id)
        }
        
        return cell
    }
    
    // MARK: - Request Handling
    private func handleAcceptRequest(requestId: String) {
        FriendService.shared.acceptFriendRequest(requestId: requestId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadFriendRequests()
                case .failure(let error):
                    self?.showAlert(message: "Accept failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleDeclineRequest(requestId: String) {
        FriendService.shared.declineFriendRequest(requestId: requestId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadFriendRequests()
                case .failure(let error):
                    self?.showAlert(message: "Decline failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Alert Helper
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
