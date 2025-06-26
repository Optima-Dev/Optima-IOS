import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var helpRequestButton: UIButton!

    private var friendRequests: [FriendRequest] = []
    private var acceptedRequestIds: Set<String> = []
    private var declinedRequestIds: Set<String> = []

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        loadFriendRequests()
    }

    private func loadFriendRequests() {
        FriendService.shared.fetchFriendRequests { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()

                switch result {
                case .success(let requests):
                    self?.friendRequests = requests

                    for id in self?.acceptedRequestIds ?? [] {
                        if !(self?.friendRequests.contains { $0.id == id } ?? false),
                           let request = self?.createFakeRequest(for: id) {
                            self?.friendRequests.append(request)
                        }
                    }

                    for id in self?.declinedRequestIds ?? [] {
                        if !(self?.friendRequests.contains { $0.id == id } ?? false),
                           let request = self?.createFakeRequest(for: id) {
                            self?.friendRequests.append(request)
                        }
                    }

                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func createFakeRequest(for id: String) -> FriendRequest? {
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

    @IBAction func goToHelpRequest(_ sender: UIButton) {
        // Instantly push the HelpRequest screen
        if let helpVC = storyboard?.instantiateViewController(withIdentifier: "HelpRequestViewController") {
            navigationController?.pushViewController(helpVC, animated: true)
        }

        // Button slide animation (executed after navigation)
        UIView.animate(withDuration: 0.4) {
            self.notificationsButton.transform = CGAffineTransform(translationX: -170, y: 0)
            self.notificationsButton.alpha = 0

            self.helpRequestButton.transform = .identity
            self.helpRequestButton.alpha = 1
        }
    }
}
