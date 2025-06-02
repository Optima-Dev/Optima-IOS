import UIKit

class MyPeopleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editFirstNameField: UITextField!
    @IBOutlet weak var editLastNameField: UITextField!
    @IBOutlet weak var removeButton: UIButton!
    
    var friends: [Friend] = []
    var selectedFriend: Friend?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupEditView()
        setupBackground()
        setupKeyboardDismiss()
        fetchFriends()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        //  Fix cell size 
        tableView.rowHeight = 65
        tableView.estimatedRowHeight = 65
    }
    
    private func setupEditView() {
        editView.isHidden = true
        editView.layer.cornerRadius = 16
        editView.layer.shadowOpacity = 0.1
        removeButton.tintColor = .systemRed
    }
    
    private func setupBackground() {
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Data Operations
    private func fetchFriends() {
        FriendService.shared.fetchFriends { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friends):
                    self?.friends = friends
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func saveChangesTapped(_ sender: UIButton) {
        guard let friend = selectedFriend,
              let firstName = editFirstNameField.text?.trimmingCharacters(in: .whitespaces),
              let lastName = editLastNameField.text?.trimmingCharacters(in: .whitespaces),
              !firstName.isEmpty, !lastName.isEmpty else {
            showAlert(message: "Please enter valid names")
            return
        }
        
        FriendService.shared.updateFriend(
            friendId: friend.id,
            firstName: firstName,
            lastName: lastName
        ) { [weak self] _ in
            self?.fetchFriends()
            self?.editView.isHidden = true
        }
    }
    
    @IBAction func removeFriendTapped(_ sender: UIButton) {
        guard let friend = selectedFriend else { return }
        confirmDelete(friend: friend)
    }
    
    // MARK: - Helper Methods
    private func confirmDelete(friend: Friend) {
        let alert = UIAlertController(
            title: "Remove Friend",
            message: "Are you sure you want to remove \(friend.firstName)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.deleteFriend(friend.id)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteFriend(_ id: String) {
        FriendService.shared.removeFriend(friendId: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchFriends()
                    self?.editView.isHidden = true
                case .failure(let error):
                    self?.showAlert(message: error.localizedDescription)
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

// MARK: - TableView Delegates
extension MyPeopleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as? FriendCell else {
            return UITableViewCell()
        }
        cell.configure(with: friends[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - FriendCell Delegate
extension MyPeopleViewController: FriendCellDelegate {
    func didTapEditButton(for friend: Friend) {
        selectedFriend = friend
        editFirstNameField.text = friend.firstName
        editLastNameField.text = friend.lastName
        editView.isHidden = false
    }
}
