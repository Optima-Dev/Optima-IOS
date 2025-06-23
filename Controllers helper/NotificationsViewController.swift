import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    private var friendRequests: [FriendRequest] = []
    private var acceptedRequestIds: Set<String> = []
    private var declinedRequestIds: Set<String> = []

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTableView()
        loadFriendRequests()
    }

    private func setupBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .none
    }

    @objc private func refreshData() {
        // Don't reset accepted/declined IDs to preserve state
        loadFriendRequests()
    }

    private func loadFriendRequests() {
        FriendService.shared.fetchFriendRequests { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()

                switch result {
                case .success(let requests):
                    self?.friendRequests = requests

                    // Merge existing accepted/declined requests that no longer come from server
                    for id in self?.acceptedRequestIds ?? [] {
                        if !(self?.friendRequests.contains { $0.id == id } ?? false) {
                            if let request = self?.createFakeRequest(for: id) {
                                self?.friendRequests.append(request)
                            }
                        }
                    }

                    for id in self?.declinedRequestIds ?? [] {
                        if !(self?.friendRequests.contains { $0.id == id } ?? false) {
                            if let request = self?.createFakeRequest(for: id) {
                                self?.friendRequests.append(request)
                            }
                        }
                    }

                    self?.tableView.reloadData()

                case .failure(let error):
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
            }
        }
    }

    // This creates a dummy request if the server removes it (to keep showing its status)
    private func createFakeRequest(for id: String) -> FriendRequest? {
        // Dummy data (can be improved if needed)
        return FriendRequest(id: id, seekerId: "local", firstName: "Saved", lastName: "Request", email: "local@dummy.com")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let request = friendRequests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestCell

        let isAccepted = acceptedRequestIds.contains(request.id)
        let isRejected = declinedRequestIds.contains(request.id)

        cell.configure(with: request, isAccepted: isAccepted, isRejected: isRejected)

        cell.acceptAction = { [weak self] in
            guard let self = self else { return }

            FriendService.shared.acceptFriendRequest(requestId: request.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.acceptedRequestIds.insert(request.id)
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    case .failure(let error):
                        self.showAlert(message: "Accept failed: \(error.localizedDescription)")
                    }
                }
            }
        }

        cell.declineAction = { [weak self] in
            guard let self = self else { return }

            FriendService.shared.declineFriendRequest(requestId: request.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.declinedRequestIds.insert(request.id)
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    case .failure(let error):
                        self.showAlert(message: "Decline failed: \(error.localizedDescription)")
                    }
                }
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let inset: CGFloat = 20
        cell.contentView.frame = cell.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset))
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
