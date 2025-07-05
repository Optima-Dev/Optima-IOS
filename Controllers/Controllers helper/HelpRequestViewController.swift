import UIKit

class HelpRequestViewController: UIViewController {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var helpRequestButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!

    private var backgroundImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupBackground()
        checkHelpRequest()
    }

    private func setupBackground() {
        backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundImageView, at: 0)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func checkHelpRequest() {
        HelpRequestService.shared.checkPendingHelpRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let hasRequest):
                    self?.updateUI(hasPending: hasRequest)
                case .failure:
                    self?.updateUI(hasPending: false)
                }
            }
        }
    }

    private func updateUI(hasPending: Bool) {
        if hasPending {
            backgroundImageView.image = UIImage(named: "helpReq1")
            acceptButton.backgroundColor = UIColor(hex: "#2727C4")
            acceptButton.setTitleColor(.white, for: .normal)
            acceptButton.isEnabled = true
        } else {
            backgroundImageView.image = UIImage(named: "helpReq2")
            acceptButton.backgroundColor = UIColor(hex: "#5E5E5E")
            acceptButton.setTitleColor(.white, for: .normal)
            acceptButton.isEnabled = false
        }
    }

    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        acceptButton.isEnabled = false
        HelpRequestService.shared.acceptHelpRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Token received: \(response.data?.token ?? "no token")")
                    self?.navigateToCall()
                case .failure(let error):
                    self?.showError(error)
                    self?.acceptButton.isEnabled = true
                }
            }
        }
    }

    private func navigateToCall() {
        let vc = HelperVideoCallViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func goToNotifications(_ sender: UIButton) {
        if let notiVC = storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") {
            navigationController?.pushViewController(notiVC, animated: true)
        }

        UIView.animate(withDuration: 0.4) {
            self.helpRequestButton.transform = CGAffineTransform(translationX: 170, y: 0)
            self.helpRequestButton.alpha = 0

            self.notificationButton.transform = .identity
            self.notificationButton.alpha = 1
        }
    }
}
