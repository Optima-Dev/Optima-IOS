import UIKit

class MyPeopleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var addNewMemberButton: UIButton!
    @IBOutlet weak var editFirstNameTextField: UITextField!
    @IBOutlet weak var editLastNameTextField: UITextField!
    @IBOutlet weak var editEmailTextField: UITextField!

    var friends: [Friend] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchFriendsList()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustTableViewFrame()
    }

    private func setupUI() {
        setupTableView()
        setupEditView()
        setupBackground()
        setupGestures()
    }

    private func adjustTableViewFrame() {
        let buttonBottomY = addNewMemberButton.frame.maxY
        tableView.frame = CGRect(
            x: 0,
            y: buttonBottomY + 10,
            width: view.frame.width,
            height: view.frame.height - buttonBottomY - 10
        )
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.layer.masksToBounds = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
    }

    private func setupEditView() {
        editView.isHidden = true
        editView.layer.cornerRadius = 15
        editView.layer.shadowColor = UIColor.black.cgColor
        editView.layer.shadowOpacity = 0.2
        editView.layer.shadowOffset = CGSize(width: 0, height: 5)
        editView.layer.shadowRadius = 10
    }

    private func setupBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideEditView))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        editView.addGestureRecognizer(panGesture)
    }

    // MARK: - API Call
    func fetchFriendsList() {
        APIManager.shared.fetchFriends { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friends):
                    self?.updateFriendsList(with: friends)
                case .failure:
                    self?.loadMockData()
                }
            }
        }
    }

    private func updateFriendsList(with friends: [Friend]) {
        self.friends = friends
        if friends.isEmpty {
            tableView.setEmptyMessage("No friends found.")
        } else {
            tableView.restore()
        }
        tableView.reloadData()
    }

    private func loadMockData() {
        friends = [
            Friend(id: "1", firstName: "John", lastName: "Doe", email: "john.doe@example.com"),
            Friend(id: "2", firstName: "Jane", lastName: "Smith", email: "jane.smith@example.com")
        ]
        tableView.restore()
        tableView.reloadData()
    }
}

// MARK: - UITableView Methods
extension MyPeopleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as? FriendCell else {
            return UITableViewCell()
        }
        let friend = friends[indexPath.row]
        cell.configure(with: friend)
        cell.delegate = self
        return cell
    }
}

// MARK: - FriendCell Delegate
extension MyPeopleViewController: FriendCellDelegate {
    func didTapEditButton(for friend: Friend) {
        editFirstNameTextField.text = friend.firstName
        editLastNameTextField.text = friend.lastName
        editEmailTextField.text = friend.email
        editView.isHidden = false
    }
}

// MARK: - Edit View Handling
extension MyPeopleViewController {
    
    @objc private func hideEditView(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: view)
        if !editView.frame.contains(touchLocation) {
            editView.isHidden = true
        }
    }

    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: editView)
        if translation.y > 100 {
            editView.isHidden = true
        }
    }
}

// MARK: - UITableView Extension
extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
