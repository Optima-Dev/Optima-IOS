import UIKit

class MyPeopleViewController: SeekerBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editFirstNameField: UITextField!
    @IBOutlet weak var editLastNameField: UITextField!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editEmailField: UITextField!
    @IBOutlet weak var initialsView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton! 

    private var darkOverlayView: UIView?

    var friends: [Friend] = []
    var selectedFriend: Friend?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupEditView()
        setupBackground()
        setupKeyboardDismiss()
        fetchFriends()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 65
        tableView.estimatedRowHeight = 65
    }

    private func setupEditView() {
        editView.isHidden = true
        editView.layer.cornerRadius = 16
        editView.layer.shadowOpacity = 0.1

        configureTextField(editFirstNameField, icon: "personIcon", placeholder: "First Name")
        configureTextField(editLastNameField, icon: "personIcon", placeholder: "Last Name")
        configureTextField(editEmailField, icon: "mail", placeholder: "example@gmail.com")

        saveButton.layer.cornerRadius = 20
        saveButton.layer.borderWidth = 4
        saveButton.layer.borderColor = UIColor(hex: "#2727C4").cgColor

        removeButton.layer.borderWidth = 0
        removeButton.layer.cornerRadius = 20
        removeButton.tintColor = .white
        removeButton.backgroundColor = UIColor.red

        initialsView.layer.cornerRadius = initialsView.frame.width / 2
        initialsView.clipsToBounds = true

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissEditView))
        swipeDown.direction = .down
        editView.addGestureRecognizer(swipeDown)
    }

    private func setupBackground() {
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOrEditView(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboardOrEditView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        let location = sender.location(in: view)
        if !editView.isHidden, !editView.frame.contains(location) {
            dismissEditView()
        }
    }

    @objc private func dismissEditView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.editView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            self.darkOverlayView?.alpha = 0
        }) { _ in
            self.editView.isHidden = true
            self.editView.transform = .identity
            self.darkOverlayView?.removeFromSuperview()
        }
    }

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
            DispatchQueue.main.async {
                self?.fetchFriends()
                self?.dismissEditView()
            }
        }
    }

    @IBAction func removeFriendTapped(_ sender: UIButton) {
        guard let friend = selectedFriend else { return }
        confirmDelete(friend: friend)
    }

    @IBAction func callButtonTapped(_ sender: UIButton) {
        guard let friend = selectedFriend else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SeekerVideoCallViewController") as? SeekerVideoCallViewController {
            vc.modalPresentationStyle = .fullScreen  
            vc.helperId = friend.id
            vc.callType = .friend
            self.present(vc, animated: true)
        }
    }

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
                    self?.dismissEditView()
                case .failure(let error):
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        }
    }

    private func configureTextField(_ textField: UITextField, icon: String, placeholder: String) {
        let iconView = UIImageView(image: UIImage(named: icon))
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 12, y: 0, width: 24, height: 24)

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        containerView.addSubview(iconView)

        textField.leftView = containerView
        textField.leftViewMode = .always
        textField.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 20
        textField.backgroundColor = UIColor.clear
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1),
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

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

extension MyPeopleViewController: FriendCellDelegate {
    func didTapEditButton(for friend: Friend) {
        selectedFriend = friend
        editFirstNameField.text = friend.firstName
        editLastNameField.text = friend.lastName
        editEmailField.text = friend.email
        initialsLabel.text = "\(friend.firstName.prefix(1).uppercased())\(friend.lastName.prefix(1).uppercased())"
        userNameLabel.text = "\(friend.firstName) \(friend.lastName)"
        editView.isHidden = false

        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlay.tag = 999
        view.insertSubview(overlay, belowSubview: editView)
        darkOverlayView = overlay
    }
}
