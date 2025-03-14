import UIKit

class MyPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editFirstNameTextField: UITextField!
    @IBOutlet weak var editLastNameTextField: UITextField!
    @IBOutlet weak var editEmailTextField: UITextField!

    var friends: [Friend] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        editView.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideEditView))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        editView.addGestureRecognizer(panGesture)

        loadTestFriends()
    }
    
    func loadTestFriends() {
        friends = [
            Friend(id: "1", firstName: "Ahmed", lastName: "Ali", email: "ahmed@example.com"),
            Friend(id: "2", firstName: "Sara", lastName: "Mahmoud", email: "sara@example.com")
        ]
        tableView.reloadData()
        print("🟢 Test Friends Loaded Successfully")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        let friend = friends[indexPath.row]
        cell.configure(with: friend)
        cell.delegate = self
        return cell
    }

    @objc func hideEditView(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: view)
        if !editView.frame.contains(touchLocation) {
            editView.isHidden = true
        }
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: editView)
        if translation.y > 100 {
            editView.isHidden = true
        }
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
/*import UIKit

class MyPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editFirstNameTextField: UITextField!
    @IBOutlet weak var editLastNameTextField: UITextField!
    @IBOutlet weak var editEmailTextField: UITextField!

    var friends: [Friend] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Hide edit view initially
        editView.isHidden = true

        // Add tap gesture to hide editView when clicking outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideEditView))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Add pan gesture for dismissing editView when swiping down
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        editView.addGestureRecognizer(panGesture)

        fetchFriendsList()
    }
    
    // Fetch the list of friends from API
    func fetchFriendsList() {
        APIManager.shared.fetchFriends { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friends):
                    self?.friends = friends
                    self?.tableView.reloadData()
                    print("🟢 Friends List Loaded Successfully")
                    
                    if friends.isEmpty {
                        print("⚠️ No friends found! Try adding some.")
                    }

                case .failure(let error):
                    print("🔴 Error fetching friends: \(error)")
                }
            }
        }
    }

    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        let friend = friends[indexPath.row]
        cell.configure(with: friend)
        cell.delegate = self  // Assign delegate for handling edit actions
        return cell
    }

    // MARK: - Hide EditView when tapping outside
    @objc func hideEditView(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: view)
        if !editView.frame.contains(touchLocation) {
            editView.isHidden = true
        }
    }
    
    // MARK: - Hide EditView when swiping down
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: editView)
        if translation.y > 100 { // If swiped down enough
            editView.isHidden = true
        }
    }
}

// MARK: - FriendCell Delegate
extension MyPeopleViewController: FriendCellDelegate {
    func didTapEditButton(for friend: Friend) {
        // Populate edit view with friend's data
        editFirstNameTextField.text = friend.firstName
        editLastNameTextField.text = friend.lastName
        editEmailTextField.text = friend.email

        // Show edit view
        editView.isHidden = false
    }
}
*/
